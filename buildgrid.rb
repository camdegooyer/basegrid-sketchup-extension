# frozen_string_literal: true

require "sketchup.rb"
require "extensions.rb"

module Buildgrid
  EXTENSION_NAME = "Buildgrid"
  EXTENSION_VERSION = "0.1.0"

  unless file_loaded?(__FILE__)
    extension = SketchupExtension.new(EXTENSION_NAME, File.join(__dir__, "buildgrid", "main"))
    extension.description = "Construction drawing tools with synced material metadata and takeoff."
    extension.version = EXTENSION_VERSION
    extension.creator = "Overland Builders"
    Sketchup.register_extension(extension, true)
    file_loaded(__FILE__)
  end
end
