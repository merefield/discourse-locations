# frozen_string_literal: true
require "rails_helper"

RSpec.describe "User can manage their location" do
  fab!(:user)
  let(:user_preferences_profile_page) { PageObjects::Pages::UserPreferencesProfile.new }
  let(:location_selector) do
    PageObjects::Components::LocationSelector.new ".location-selector-wrapper"
  end
  fab!(:address_string) do
    "Hope Street, Canning / Georgian Quarter, Toxteth, Liverpool, Liverpool City Region, England, L1 9BW, United Kingdom"
  end
  let(:location) do
    {
      "place_id" => 256_934_900,
      "licence" => "Data © OpenStreetMap contributors, ODbL 1.0. http://osm.org/copyright",
      "osm_type" => "way",
      "osm_id" => 4_086_265,
      "lat" => "53.4011822",
      "lon" => "-2.9706263",
      "class" => "highway",
      "type" => "tertiary",
      "place_rank" => 26,
      "importance" => 0.30430544025715084,
      "addresstype" => "road",
      "name" => "Hope Street",
      "address" => address_string,
      "boundingbox" => %w[53.3986907 53.4034963 -2.9714089 -2.9693595],
    }
  end

  context "browsing the users preferences" do
    before(:each) do
      SiteSetting.location_enabled = true
      SiteSetting.location_users_map = true
      sign_in(user)
      UserCustomField.create!(user_id: user.id, name: "geo_location", value: location.to_json)
    end

    it "allows user to view and update their location preferences" do
      user_preferences_profile_page.visit(user)
      expect(page).to have_css(".location-selector-wrapper")
      expect(location_selector).to have_selected_location_with_string(address_string)
      location_selector.remove_location(address_string)
      expect(location_selector).to have_no_selected_locations
      user_preferences_profile_page.save
      page.refresh
      expect(location_selector).to have_no_selected_locations
    end
  end
end
