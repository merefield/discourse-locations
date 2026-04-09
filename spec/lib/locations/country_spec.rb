# frozen_string_literal: true

require "rails_helper"

describe Locations::Country do
  describe ".config_path" do
    it "resolves paths relative to the plugin root" do
      expect(described_class.config_path("country_codes.yml")).to eq(
        File.join(File.expand_path("../../..", __dir__), "config", "country_codes.yml"),
      )
    end
  end

  describe ".codes" do
    it "loads the country code data" do
      expect(described_class.codes).to include(code: "gb", name: "United Kingdom")
    end
  end
end
