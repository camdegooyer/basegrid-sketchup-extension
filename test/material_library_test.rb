# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"

module Basegrid
  EXTENSION_VERSION = "test" unless const_defined?(:EXTENSION_VERSION)
end

require_relative "../basegrid/material_library"

class MaterialLibraryTest < Minitest::Test
  Response = Struct.new(:status, :body, :etag, :content_type, keyword_init: true)

  class FakeClient
    attr_reader :etags

    def initialize(payload)
      @payload = payload
      @etags = []
    end

    def get_json(_url, token:, etag: nil)
      raise "missing token" if token.empty?

      @etags << etag
      Response.new(status: 200, body: @payload, etag: "snapshot-1")
    end

    def get_image(_url, token: nil)
      Response.new(status: 200, body: "image", content_type: "image/png")
    end
  end

  def test_syncs_and_filters_active_bulk_m3_concrete_materials
    Dir.mktmpdir do |directory|
      library = Basegrid::MaterialLibrary.new(
        cache_path: File.join(directory, "materials.json"),
        texture_directory: File.join(directory, "textures"),
        client: FakeClient.new(payload)
      )

      result = library.sync!(url: "https://example.test/library", token: "token")

      assert result[:changed]
      assert_equal ["N25 Concrete"], library.concrete_materials.map { |material| material.fetch("name") }
      assert File.file?(File.join(directory, "materials.json"))
    end
  end

  def test_sync_reports_real_stages_without_changing_result_contract
    Dir.mktmpdir do |directory|
      library = Basegrid::MaterialLibrary.new(cache_path: File.join(directory,"cache.json"),
        texture_directory: File.join(directory,"textures"),client: FakeClient.new(web_api_payload))
      events = []
      result = library.sync!(url: "https://example.test/library",token: "token") { |event| events << event }
      assert_equal %w[cache download materials textures save],events.map { |event| event[:stage] }.uniq
      assert_equal result[:materials],events.find { |event| event[:stage] == "materials" }[:materials]
      texture = events.select { |event| event[:stage] == "textures" }.last
      assert_equal 1,texture[:total]
      assert_equal texture[:total],texture[:completed]
    end
  end

  def test_rejects_materials_that_reference_unknown_types
    invalid = payload
    invalid["materials"][0]["material_type_id"] = "missing"

    error = assert_raises(RuntimeError) do
      Dir.mktmpdir do |directory|
        library = Basegrid::MaterialLibrary.new(
          cache_path: File.join(directory, "materials.json"),
          texture_directory: File.join(directory, "textures"),
          client: FakeClient.new(invalid)
        )
        library.sync!(url: "https://example.test/library", token: "token")
      end
    end
    assert_includes error.message, "unknown material type"
  end

  def test_replaces_an_existing_cache_and_sends_its_etag
    Dir.mktmpdir do |directory|
      cache = File.join(directory, "materials.json")
      client = FakeClient.new(payload)
      library = Basegrid::MaterialLibrary.new(
        cache_path: cache,
        texture_directory: File.join(directory, "textures"),
        client: client
      )

      library.sync!(url: "https://example.test/library", token: "token")
      library.sync!(url: "https://example.test/library", token: "token")

      assert_equal [nil, "snapshot-1"], client.etags
      assert_equal "snapshot-1", JSON.parse(File.read(cache)).fetch("etag")
      refute File.exist?("#{cache}.previous")
    end
  end

  def test_normalizes_the_web_api_v1_response
    Dir.mktmpdir do |directory|
      library = Basegrid::MaterialLibrary.new(
        cache_path: File.join(directory, "materials.json"),
        texture_directory: File.join(directory, "textures"),
        client: FakeClient.new(web_api_payload)
      )

      library.sync!(url: "https://example.test/library", token: "token")

      material = library.concrete_materials.fetch(0)
      assert_equal "n25", material["id"]
      assert_equal "concrete-type", material["material_type_id"]
      assert_equal "texture-1", material.dig("texture", "id")
      assert_equal "https://example.test/concrete.png", material.dig("texture", "image_url")
      assert_equal "display-1", material.dig("display_texture", "id")
      assert_equal ["Concrete", "Slabs"], library.takeoff_groups_for_role(
        "concrete.slab_from_face.slab_body"
      ).map { |group| group["name"] }
    end
  end

  def test_rejects_generated_roles_with_unknown_takeoff_groups
    invalid = payload
    invalid["generated_roles"] = [
      {
        "id" => "concrete.slab_from_face.slab_body",
        "tool_id" => "concrete.slab_from_face",
        "takeoff_group_ids" => ["missing"]
      }
    ]

    error = assert_raises(RuntimeError) do
      Dir.mktmpdir do |directory|
        Basegrid::MaterialLibrary.new(
          cache_path: File.join(directory, "materials.json"),
          texture_directory: File.join(directory, "textures"),
          client: FakeClient.new(invalid)
        ).sync!(url: "https://example.test/library", token: "token")
      end
    end

    assert_includes error.message, "unknown takeoff groups"
  end

  private

  def payload
    {
      "schema_version" => 1,
      "material_types" => [
        { "id" => "concrete-type", "name" => "Concrete", "profile" => "bulk", "uom" => "m3", "status" => "active" },
        { "id" => "fill-type", "name" => "Fill", "profile" => "bulk", "uom" => "m3", "status" => "active" }
      ],
      "materials" => [
        { "id" => "n25", "material_type_id" => "concrete-type", "name" => "N25 Concrete", "status" => "active" },
        { "id" => "retired", "material_type_id" => "concrete-type", "name" => "Old Concrete", "status" => "retired" },
        { "id" => "fill", "material_type_id" => "fill-type", "name" => "Compacted Fill", "status" => "active" }
      ],
      "takeoff_groups" => [],
      "generated_roles" => []
    }
  end

  def web_api_payload
    {
      "api_version" => "v1",
      "organisation" => { "id" => "org-1", "name" => "Example" },
      "material_types" => [
        {
          "id" => "concrete-type",
          "name" => "Concrete",
          "profile" => "bulk",
          "uom" => "m3",
          "status" => "active",
          "materials" => [
            {
              "id" => "n25",
              "name" => "N25 Concrete",
              "status" => "active",
              "construction_texture" => {
                "texture_id" => "texture-1",
                "signed_url" => "https://example.test/concrete.png",
                "width_mm" => 1000,
                "height_mm" => 1000
              },
              "display_texture" => {
                "texture_id" => "display-1",
                "signed_url" => nil,
                "color" => "#808080"
              }
            }
          ]
        }
      ],
      "takeoff_groups" => [
        { "id" => "slabs", "name" => "Slabs", "status" => "active" },
        { "id" => "concrete", "name" => "Concrete", "status" => "active" },
        { "id" => "retired-group", "name" => "Old group", "status" => "retired" }
      ],
      "generated_roles" => [
        {
          "id" => "concrete.slab_from_face.slab_body",
          "tool_id" => "concrete.slab_from_face",
          "takeoff_group_ids" => ["slabs", "concrete", "retired-group"]
        }
      ]
    }
  end
end
