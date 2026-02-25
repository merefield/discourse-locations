# frozen_string_literal: true

require "rails_helper"

RSpec.describe ::Locations::UsersMapController do
  describe "GET /locations/users-map" do
    it "returns success for the canonical users-map route when plugin is enabled" do
      SiteSetting.location_enabled = true

      get "/locations/users-map"

      expect(response.status).to eq(200)
      expect(response.parsed_body["success"]).to eq("OK")
    end

    it "returns not found when plugin is disabled" do
      SiteSetting.location_enabled = false

      get "/locations/users-map"

      expect(response.status).to eq(404)
    end

    it "does not route the legacy users_map path" do
      SiteSetting.location_enabled = true

      get "/locations/users_map"

      expect(response.status).to eq(404)
    end
  end
end
