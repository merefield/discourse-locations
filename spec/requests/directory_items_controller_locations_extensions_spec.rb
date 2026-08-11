# frozen_string_literal: true
require "rails_helper"

RSpec.describe DirectoryItemsController do
  fab!(:user)

  describe "#index" do
    context "when browsing the regular directory" do
      before do
        SiteSetting.location_enabled = true
        SiteSetting.location_users_map = true
        SiteSetting.enable_user_directory = true
        sign_in(user)
      end

      it "serializes user locations as objects" do
        UserCustomField.create!(
          user: user,
          name: "geo_location",
          value: { lat: "51.5074", lon: "-0.1278" }.to_json
        )
        DirectoryItem.refresh!

        get "/directory_items.json", params: { period: "all" }

        expect(response.status).to eq(200)
        directory_user =
          response.parsed_body["directory_items"].find do |item|
            item.dig("user", "id") == user.id
          end
        expect(directory_user.dig("user", "geo_location")).to eq(
          { "lat" => "51.5074", "lon" => "-0.1278" }
        )
      end
    end

    context "when browsing the users map" do
      before do
        SiteSetting.location_enabled = true
        sign_in(user)
      end

      it "returns the minimal map payload" do
        SiteSetting.enable_names = true
        map_user = Fabricate(:user, name: "Map User")
        UserCustomField.create!(
          user: map_user,
          name: "geo_location",
          value: {
            lat: "51.5074",
            lon: "-0.1278",
            address: "London, United Kingdom"
          }.to_json
        )
        Locations::UserLocationProcess.upsert(map_user.id)
        DirectoryItem.refresh_period!(:daily, force: true)

        SiteSetting.location_users_map = true
        SiteSetting.enable_user_directory = true
        get "/directory_items.json?period=location"

        expect(response.status).to eq(200)
        expect(response.parsed_body["directory_items"]).to contain_exactly(
          {
            "id" => map_user.id,
            "user" => {
              "id" => map_user.id,
              "username" => map_user.username,
              "name" => map_user.name,
              "avatar_template" => map_user.avatar_template,
              "geo_location" => {
                "lat" => "51.5074",
                "lon" => "-0.1278"
              }
            }
          }
        )
      end

      it "orders users by most recent activity" do
        older_user = Fabricate(:user)
        older_user.update_columns(last_seen_at: 2.days.ago)
        newer_user = Fabricate(:user)
        newer_user.update_columns(last_seen_at: 1.hour.ago)

        [older_user, newer_user].each do |map_user|
          UserCustomField.create!(
            user: map_user,
            name: "geo_location",
            value: { lat: "51.5074", lon: "-0.1278" }.to_json
          )
          Locations::UserLocationProcess.upsert(map_user.id)
        end
        DirectoryItem.refresh_period!(:daily, force: true)

        SiteSetting.location_users_map = true
        SiteSetting.enable_user_directory = true
        get "/directory_items.json?period=location"

        expect(response.status).to eq(200)
        expect(
          response.parsed_body["directory_items"].map { |item| item["id"] }
        ).to eq([newer_user.id, older_user.id])
      end

      it "returns forbidden when the user directory is disabled" do
        SiteSetting.location_users_map = true
        SiteSetting.enable_user_directory = false
        get "/directory_items.json?period=location"
        expect(response.status).to eq(403)
        expect(response.parsed_body["error_type"]).to eq("invalid_access")
      end

      it "returns forbidden when the users map is disabled" do
        SiteSetting.location_users_map = false
        SiteSetting.enable_user_directory = true
        get "/directory_items.json?period=location"
        expect(response.status).to eq(403)
        expect(response.parsed_body["error_type"]).to eq("invalid_access")
      end
    end

    context "when profiles are hidden from anonymous users" do
      before do
        SiteSetting.location_users_map = true
        SiteSetting.enable_user_directory = true
        SiteSetting.hide_user_profiles_from_public = true
      end

      it "returns forbidden to an anonymous user" do
        get "/directory_items.json?period=location"
        expect(response.status).to eq(403)
        expect(response.parsed_body["error_type"]).to eq("invalid_access")
      end
    end
  end
end
