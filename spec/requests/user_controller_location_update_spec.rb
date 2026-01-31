# frozen_string_literal: true
require "rails_helper"

RSpec.describe UsersController do
  fab!(:user) do
    token = SecureRandom.hex(6)
    Fabricate(:user, email: "user-loc-#{token}@example.com", username: "userloc#{token}")
  end
  let!(:user_field) { Fabricate(:user_field, editable: true) }

  before do
    sign_in(user)
    SiteSetting.location_enabled = true
    SiteSetting.location_users_map = true
  end

  def parsed_geo_location_for(user)
    user.reload
    raw = user.custom_fields["geo_location"]
    return nil if raw.blank? || raw == "{}"

    raw.is_a?(String) ? JSON.parse(raw) : raw
  end

  context "locations plugin checks for valid geolocation parameters which at minimum need to include both latitude and longitude" do
    it "allows user to upload valid geolocation to their profile" do
      put "/u/#{user.username}.json",
          params: {
            custom_fields: {
              geo_location: { lat: 10, lon: 12 }.to_json,
            },
          }

      expect(response.status).to eq(200)
      result = response.parsed_body
      expect(result["success"]).to eq("OK")

      geo = parsed_geo_location_for(user)
      expect(geo["lat"].to_s).to eq("10")
      expect(geo["lon"].to_s).to eq("12")
    end

    it "doesn't allow user to upload invalid geolocation to their profile" do
      put "/u/#{user.username}.json",
          params: {
            custom_fields: {
              geo_location: { lat: 10 }.to_json,
            },
          }

      expect(response.status).to eq(400)
      result = response.parsed_body
      expect(result["error_type"]).to eq("invalid_parameters")
    end

    it "allows user to upload a different custom user field who doesn't have a location" do
      put "/u/#{user.username}.json",
          params: {
            user_fields: {
              user_field.id.to_s => "happy",
            },
          }

      expect(response.status).to eq(200)
      result = response.parsed_body
      expect(result["success"]).to eq("OK")

      user.reload
      expect(user.user_fields[user_field.id.to_s]).to eq("happy")
    end

    it "allows user to clear their geolocation (no location)" do
      # seed a location first
      UserCustomField.create!(
        user_id: user.id,
        name: "geo_location",
        value: { lat: 1, lon: 2, address: "Somewhere" }.to_json,
      )

      put "/u/#{user.username}.json",
          params: {
            custom_fields: {
              geo_location: "",
            },
          }

      expect(response.status).to eq(200)
      result = response.parsed_body
      expect(result["success"]).to eq("OK")

      user.reload
      # cleared means blank string or missing key depending on upstream behavior
      expect(user.custom_fields["geo_location"]).to be_blank
    end
  end
end
