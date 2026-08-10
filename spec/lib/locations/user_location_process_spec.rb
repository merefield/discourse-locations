# frozen_string_literal: true

require "rails_helper"

RSpec.describe Locations::UserLocationProcess do
  fab!(:user)

  describe ".upsert" do
    it "persists a location stored as JSON" do
      user.custom_fields["geo_location"] = {
        "lat" => "51.5074",
        "lon" => "-0.1278",
        "city" => "London",
        "countrycode" => "gb"
      }.to_json
      user.save_custom_fields

      described_class.upsert(user.id)

      expect(Locations::UserLocation.find_by(user: user)).to have_attributes(
        latitude: 51.5074,
        longitude: -0.1278,
        city: "London",
        countrycode: "gb"
      )
    end

    it "does not persist malformed location data" do
      user.custom_fields["geo_location"] = "not-json"
      user.save_custom_fields

      described_class.upsert(user.id)

      expect(Locations::UserLocation.exists?(user: user)).to eq(false)
    end
  end
end
