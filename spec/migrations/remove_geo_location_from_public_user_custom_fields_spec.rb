# frozen_string_literal: true

require_relative "../../db/migrate/20260813102208_remove_geo_location_from_public_user_custom_fields"

RSpec.describe RemoveGeoLocationFromPublicUserCustomFields do
  before do
    DB.exec(
      <<~SQL,
        INSERT INTO site_settings (name, data_type, value, created_at, updated_at)
        VALUES ('public_user_custom_fields', :data_type, :value, NOW(), NOW())
        ON CONFLICT (name) DO UPDATE SET value = EXCLUDED.value
      SQL
      data_type: SiteSettings::TypeSupervisor.types[:list],
      value: "department|geo_location|timezone"
    )
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
