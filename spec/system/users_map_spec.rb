# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Users map" do
  fab!(:admin)

  def create_user_with_location(lat:, lon:, suffix:)
    user = Fabricate(:user)

    UserCustomField.create!(
      user_id: user.id,
      name: "geo_location",
      value: { lat: lat, lon: lon }.to_json,
    )

    Locations::UserLocation.create!(user_id: user.id, latitude: lat, longitude: lon)
    user
  end

  it "shows markers for users with locations" do
    SiteSetting.location_enabled = true
    SiteSetting.location_users_map = true
    SiteSetting.enable_user_directory = true
    SiteSetting.location_map_maker_cluster_enabled = false
    allow_any_instance_of(Locations::UserLocation).to receive(:geocode)
    allow_any_instance_of(Locations::UserLocation).to receive(:reverse_geocode)

    create_user_with_location(lat: 10.0, lon: 12.0, suffix: "a")
    create_user_with_location(lat: 11.0, lon: 13.0, suffix: "b")
    create_user_with_location(lat: 12.0, lon: 14.0, suffix: "c")

    DirectoryItem.refresh_period!(:daily, force: true)

    users_map_page = PageObjects::Pages::UsersMap.new
    sign_in(admin)
    users_map_page.visit
    users_map_page.has_marker_count?(3)
  end
end
