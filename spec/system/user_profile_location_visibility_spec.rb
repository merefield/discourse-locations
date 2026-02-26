# frozen_string_literal: true
require "rails_helper"

RSpec.describe "User profile and user card location visibility", type: :system do
  fab!(:user_with_location, :user)
  fab!(:admin)

  let(:geo_location) do
    {
      "lat" => "51.5073219",
      "lon" => "-0.1276474",
      "address" =>
        "London, Greater London, England, United Kingdom",
      "countrycode" => "gb",
      "city" => "London",
      "state" => "England",
      "country" => "United Kingdom",
      "postalcode" => "",
      "type" => "city",
    }
  end

  before do
    SiteSetting.location_enabled = true
    SiteSetting.location_users_map = true
    SiteSetting.location_user_profile_format = "city|countrycode"

    UserCustomField.create!(
      user_id: user_with_location.id,
      name: "geo_location",
      value: geo_location.to_json,
    )

    sign_in(admin)
  end

  describe "user profile page" do
    it "shows geo location in the replace-location section" do
      page.visit("/u/#{user_with_location.username}")

      expect(page).to have_css(
        ".replace-location .user-profile-location",
        visible: true,
        wait: 5,
      )
      expect(page).to have_css(
        ".replace-location .user-profile-location .location-label",
        visible: true,
        wait: 5,
      )
    end

    it "hides the native location field when user has a native location set" do
      user_with_location.update!(location: "Some Native Location")

      page.visit("/u/#{user_with_location.username}")

      # Plugin's geo location should be visible inside .replace-location
      expect(page).to have_css(
        ".replace-location .user-profile-location",
        visible: true,
        wait: 5,
      )

      # Native .user-profile-location outside .replace-location should be hidden
      # (CSS rule: .user-profile-location { display: none })
      expect(page).to have_no_css(
        ".location-and-website > div.user-profile-location",
        visible: true,
      )
    end

    it "shows website in the replace-location section when user has a website" do
      user_with_location.user_profile.update!(website: "https://example.com")

      page.visit("/u/#{user_with_location.username}")

      expect(page).to have_css(
        ".replace-location .user-profile-website",
        visible: true,
        wait: 5,
      )
      expect(page).to have_css(
        ".replace-location .user-profile-website a[href='https://example.com']",
        visible: true,
      )
    end
  end

  describe "user card" do
    fab!(:topic) { Fabricate(:topic, user: user_with_location) }
    fab!(:post_with_location) do
      Fabricate(:post, topic: topic, user: user_with_location)
    end

    it "shows geo location in the user card" do
      page.visit("/t/#{topic.slug}/#{topic.id}")

      # Open user card by clicking on the user's username link
      find(
        "a[data-user-card='#{user_with_location.username}']",
        match: :first,
      ).click

      expect(page).to have_css("#user-card", visible: true, wait: 5)

      expect(page).to have_css(
        "#user-card .location-and-website .replace-location .location",
        visible: true,
        wait: 5,
      )
      expect(page).to have_css(
        "#user-card .location-and-website .replace-location .location .location-label",
        visible: true,
      )
    end
  end
end
