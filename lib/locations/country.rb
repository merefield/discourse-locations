# frozen_string_literal: true
module ::Locations
  class Country
    PLUGIN_ROOT = File.expand_path("../..", __dir__)

    def self.codes
      raw_codes = YAML.safe_load(File.read(config_path("country_codes.yml")))
      formatted_codes = []

      raw_codes.map { |code, name| formatted_codes.push(code: code, name: name) }

      formatted_codes
    end

    def self.bounding_boxes
      YAML.safe_load(File.read(config_path("country_bounding_boxes.yml")))
    end

    def self.config_path(file_name)
      File.join(PLUGIN_ROOT, "config", file_name)
    end
  end
end
