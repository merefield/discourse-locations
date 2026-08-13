# frozen_string_literal: true

require_relative "../../db/migrate/20260813102208_remove_geo_location_from_public_user_custom_fields"

RSpec.describe RemoveGeoLocationFromPublicUserCustomFields do
  before do
    SiteSetting.public_user_custom_fields = ""
    DB.exec(<<~SQL, value: "department|geo_location|timezone")
        UPDATE site_settings
        SET value = :value
        WHERE name = 'public_user_custom_fields'
      SQL
  end

  it "removes only the plugin location field from the public fields setting" do
    described_class.new.up

    expect(
      DB.query_single(
        "SELECT value FROM site_settings WHERE name = 'public_user_custom_fields'"
      ).first
    ).to eq("department|timezone")
  end
end
