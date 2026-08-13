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

      it "does not expose location custom fields in the regular directory" do
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
        expect(directory_user["user"]).not_to have_key("geo_location")
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
        location_field =
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
        location_field.update!(
          value: {
            lat: "40.7128",
            lon: "-74.0060",
            address: "New York, United States"
          }.to_json
        )
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
                "lat" => 51.5074,
                "lon" => -0.1278
              }
            }
          }
        )
      end

      it "omits names when names are disabled" do
        SiteSetting.enable_names = false
        map_user = Fabricate(:user, name: "Private Name")
        UserCustomField.create!(
          user: map_user,
          name: "geo_location",
          value: { lat: "51.5074", lon: "-0.1278" }.to_json
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
              "avatar_template" => map_user.avatar_template,
              "geo_location" => {
                "lat" => 51.5074,
                "lon" => -0.1278
              }
            }
          }
        )
      end

      it "orders and limits users deterministically" do
        newest_user = Fabricate(:user)
        newest_user.update_columns(last_seen_at: 1.hour.ago)
        first_tied_user = Fabricate(:user)
        second_tied_user = Fabricate(:user)
        tied_last_seen_at = 1.day.ago
        [first_tied_user, second_tied_user].each do |map_user|
          map_user.update_columns(last_seen_at: tied_last_seen_at)
        end
        unseen_user = Fabricate(:user)
        unseen_user.update_columns(last_seen_at: nil)

        [
          newest_user,
          first_tied_user,
          second_tied_user,
          unseen_user
        ].each do |map_user|
          UserCustomField.create!(
            user: map_user,
            name: "geo_location",
            value: { lat: "51.5074", lon: "-0.1278" }.to_json
          )
          Locations::UserLocationProcess.upsert(map_user.id)
        end
        DirectoryItem.refresh_period!(:daily, force: true)

        SiteSetting.location_users_map = true
        SiteSetting.location_users_map_limit = 3
        SiteSetting.enable_user_directory = true
        get "/directory_items.json?period=location"

        expect(response.status).to eq(200)
        tied_user_ids = [first_tied_user.id, second_tied_user.id]
        tied_user_ids.sort_by! do |user_id|
          DirectoryItem.find_by!(user_id: user_id, period_type: 5).id
        end
        expect(
          response.parsed_body["directory_items"].map { |item| item["id"] }
        ).to eq([newest_user.id, *tied_user_ids])
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
