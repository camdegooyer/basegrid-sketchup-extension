# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "net/http"
require "tempfile"
require "uri"

module Buildgrid
  class MaterialLibrary
    SCHEMA_VERSION = 1
    DEFAULT_URL = "https://buildgrid.overlandbuilders.co/api/v1/material-library"
    CONNECTION_URL = "https://buildgrid.overlandbuilders.co/app/connections"
    MAX_TEXTURE_BYTES = 20 * 1024 * 1024
    IMAGE_CONTENT_TYPES = {
      "image/jpeg" => ".jpg",
      "image/png" => ".png"
    }.freeze

    class HttpClient
      Response = Struct.new(:status, :body, :etag, :content_type, keyword_init: true)

      def get_json(url, token:, etag: nil)
        response = request(url, token: token, etag: etag)
        return response if response.status == 304

        response.body = JSON.parse(response.body)
        response
      rescue JSON::ParserError => e
        raise "Material library returned invalid JSON: #{e.message}"
      end

      def get_image(url, token: nil)
        response = request(url, token: token, max_bytes: MAX_TEXTURE_BYTES)
        content_type = response.content_type.to_s.split(";").first
        unless IMAGE_CONTENT_TYPES.key?(content_type)
          raise "Texture response has unsupported content type #{content_type.inspect}."
        end

        response
      end

      private

      def request(url, token:, etag: nil, max_bytes: nil)
        uri = URI.parse(url.to_s)
        unless uri.is_a?(URI::HTTPS) || local_http?(uri)
          raise "Material sync only permits HTTPS URLs (HTTP is allowed for local development)."
        end

        request = Net::HTTP::Get.new(uri.request_uri)
        request["Authorization"] = "Bearer #{token}" unless token.to_s.empty?
        request["If-None-Match"] = etag unless etag.to_s.empty?
        request["User-Agent"] = "Buildgrid-SketchUp/#{Buildgrid::EXTENSION_VERSION}"

        response = Net::HTTP.start(
          uri.host,
          uri.port,
          use_ssl: uri.is_a?(URI::HTTPS),
          open_timeout: 10,
          read_timeout: 30
        ) { |http| http.request(request) }

        status = response.code.to_i
        unless [200, 304].include?(status)
          raise "Material sync failed with HTTP #{status}."
        end
        if max_bytes && response.body.to_s.bytesize > max_bytes
          raise "Texture exceeds the #{max_bytes / (1024 * 1024)} MB download limit."
        end

        Response.new(
          status: status,
          body: response.body.to_s,
          etag: response["ETag"],
          content_type: response["Content-Type"]
        )
      rescue URI::InvalidURIError
        raise "Material sync URL is invalid."
      end

      def local_http?(uri)
        uri.is_a?(URI::HTTP) && ["localhost", "127.0.0.1", "::1"].include?(uri.host)
      end
    end

    attr_reader :cache_path, :texture_directory

    def self.default_data_directory
      if ENV["LOCALAPPDATA"] && !ENV["LOCALAPPDATA"].empty?
        File.join(ENV["LOCALAPPDATA"], "Buildgrid")
      elsif RUBY_PLATFORM.include?("darwin")
        File.expand_path("~/Library/Application Support/Buildgrid")
      else
        File.expand_path("~/.buildgrid")
      end
    end

    def initialize(cache_path: nil, texture_directory: nil, client: HttpClient.new)
      data_directory = self.class.default_data_directory
      @cache_path = cache_path || File.join(data_directory, "material-library.json")
      @texture_directory = texture_directory || File.join(data_directory, "textures")
      @client = client
      @payload = nil
    end

    def load
      return empty_payload unless File.file?(cache_path)

      parsed = JSON.parse(File.read(cache_path, encoding: "UTF-8"))
      validate!(parsed)
      @payload = parsed
    rescue JSON::ParserError, SystemCallError => e
      raise "The local material cache cannot be read: #{e.message}"
    end

    def sync!(url:, token:)
      existing = begin
        load
      rescue StandardError
        empty_payload
      end
      response = @client.get_json(url, token: token, etag: existing["etag"])
      return { changed: false, materials: materials.length, takeoff_groups: takeoff_groups.length, warnings: [] } if response.status == 304

      payload = normalize_payload(response.body)
      validate!(payload)
      warnings = cache_textures!(payload)
      payload["etag"] = response.etag unless response.etag.to_s.empty?
      atomic_write(cache_path, JSON.pretty_generate(payload))
      @payload = payload
      { changed: true, materials: materials.length, takeoff_groups: takeoff_groups.length, warnings: warnings }
    end

    def material_types
      current.fetch("material_types")
    end

    def materials
      current.fetch("materials")
    end

    def takeoff_groups
      current.fetch("takeoff_groups")
    end

    def generated_roles
      current.fetch("generated_roles")
    end

    def concrete_materials
      types = material_types.each_with_object({}) { |type, memo| memo[type.fetch("id").to_s] = type }
      materials.select do |material|
        type = types[material.fetch("material_type_id").to_s]
        active?(material) && type && active?(type) &&
          type.fetch("name").to_s.casecmp?("Concrete") &&
          type.fetch("profile").to_s == "bulk" &&
          type.fetch("uom").to_s == "m3"
      end.sort_by { |material| material.fetch("name").to_s.downcase }
    end

    def find(material_id)
      materials.find { |material| material.fetch("id").to_s == material_id.to_s }
    end

    def takeoff_groups_for_role(role_id)
      role = generated_roles.find { |candidate| candidate.fetch("id").to_s == role_id.to_s }
      return [] unless role

      allowed_ids = role.fetch("takeoff_group_ids").map(&:to_s)
      takeoff_groups.select do |group|
        allowed_ids.include?(group.fetch("id").to_s) && active?(group)
      end.sort_by { |group| group.fetch("name").to_s.downcase }
    end

    private

    def current
      @payload ||= load
    end

    def empty_payload
      @payload = {
        "schema_version" => SCHEMA_VERSION,
        "material_types" => [],
        "materials" => [],
        "takeoff_groups" => [],
        "generated_roles" => []
      }
    end

    def active?(record)
      record.fetch("status", "active").to_s == "active"
    end

    def normalize_payload(payload)
      return payload if payload.is_a?(Hash) && payload.key?("schema_version")
      return payload unless payload.is_a?(Hash) && payload["api_version"] == "v1"

      materials = []
      material_types = Array(payload["material_types"]).map do |source_type|
        type = source_type.dup
        nested_materials = Array(type.delete("materials"))
        type.delete("default_texture")
        nested_materials.each do |source_material|
          material = source_material.dup
          material["material_type_id"] = type["id"]
          material["texture"] = normalize_appearance(material.delete("construction_texture"))
          material["display_texture"] = normalize_appearance(material["display_texture"])
          materials << material
        end
        type
      end

      {
        "schema_version" => SCHEMA_VERSION,
        "organisation" => payload["organisation"],
        "material_types" => material_types,
        "materials" => materials,
        "takeoff_groups" => Array(payload["takeoff_groups"]),
        "generated_roles" => Array(payload["generated_roles"])
      }
    end

    def normalize_appearance(appearance)
      return nil unless appearance.is_a?(Hash)

      normalized = appearance.dup
      normalized["id"] ||= normalized["texture_id"]
      normalized["image_url"] ||= normalized["signed_url"]
      normalized
    end

    def validate!(payload)
      raise "Material library must be a JSON object." unless payload.is_a?(Hash)
      unless payload["schema_version"].to_i == SCHEMA_VERSION
        raise "Unsupported material library schema version #{payload['schema_version'].inspect}."
      end

      types = payload["material_types"]
      items = payload["materials"]
      raise "Material library must include material_types and materials arrays." unless types.is_a?(Array) && items.is_a?(Array)

      groups = payload.fetch("takeoff_groups", [])
      roles = payload.fetch("generated_roles", [])
      raise "Takeoff groups and generated roles must be arrays." unless groups.is_a?(Array) && roles.is_a?(Array)
      payload["takeoff_groups"] = groups
      payload["generated_roles"] = roles

      type_ids = unique_ids!(types, "material type")
      unique_ids!(items, "material")
      group_ids = unique_ids!(groups, "takeoff group")
      unique_ids!(roles, "generated role")
      types.each do |type|
        %w[id name profile uom].each { |key| required!(type, key, "material type") }
      end
      items.each do |material|
        %w[id material_type_id name].each { |key| required!(material, key, "material") }
        unless type_ids.include?(material["material_type_id"].to_s)
          raise "Material #{material['id']} references an unknown material type."
        end
      end
      groups.each { |group| required!(group, "name", "takeoff group") }
      roles.each do |role|
        required!(role, "tool_id", "generated role")
        allowed_ids = role["takeoff_group_ids"]
        raise "Every generated role requires a takeoff_group_ids array." unless allowed_ids.is_a?(Array)

        unknown_ids = allowed_ids.map(&:to_s).uniq - group_ids
        unless unknown_ids.empty?
          raise "Generated role #{role['id']} references unknown takeoff groups: #{unknown_ids.join(', ')}."
        end
      end
      payload
    end

    def unique_ids!(records, label)
      ids = records.map do |record|
        raise "Every #{label} must be a JSON object." unless record.is_a?(Hash)

        required!(record, "id", label).to_s
      end
      raise "Material library contains duplicate #{label} IDs." unless ids.uniq.length == ids.length

      ids
    end

    def required!(record, key, label)
      value = record[key]
      raise "Every #{label} requires #{key}." if value.nil? || value.to_s.strip.empty?

      value
    end

    def cache_textures!(payload)
      FileUtils.mkdir_p(texture_directory)
      warnings = []
      payload.fetch("materials").each do |material|
        %w[texture display_texture].each do |role|
          appearance = material[role]
          next unless appearance.is_a?(Hash) && !appearance["image_url"].to_s.empty?

          begin
            appearance["local_path"] = cache_texture(material.fetch("id"), role, appearance)
          rescue StandardError => e
            warnings << "#{material['name']} #{role.tr('_', ' ')}: #{e.message}"
          end
        end
      end
      warnings
    end

    def cache_texture(material_id, role, appearance)
      response = @client.get_image(appearance.fetch("image_url"), token: nil)
      extension = IMAGE_CONTENT_TYPES.fetch(response.content_type.to_s.split(";").first)
      texture_identity = appearance["id"].to_s.empty? ? appearance["image_url"] : appearance["id"]
      digest = Digest::SHA256.hexdigest("#{material_id}:#{role}:#{texture_identity}")
      path = File.join(texture_directory, "#{digest}#{extension}")
      atomic_write(path, response.body, binary: true) unless File.file?(path)
      path
    end

    def atomic_write(path, content, binary: false)
      FileUtils.mkdir_p(File.dirname(path))
      temp = Tempfile.new([File.basename(path), ".tmp"], File.dirname(path))
      begin
        temp.binmode if binary
        temp.write(content)
        temp.flush
        temp.fsync
        temp.close
        backup = "#{path}.previous"
        File.delete(backup) if File.exist?(backup)
        File.rename(path, backup) if File.exist?(path)
        begin
          File.rename(temp.path, path)
          File.delete(backup) if File.exist?(backup)
        rescue StandardError
          File.rename(backup, path) if File.exist?(backup) && !File.exist?(path)
          raise
        end
      ensure
        temp.close! if temp
      end
    end
  end
end
