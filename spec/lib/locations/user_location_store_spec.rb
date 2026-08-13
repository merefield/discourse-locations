# frozen_string_literal: true

RSpec.describe Locations::UserLocationStore do
  fab!(:user)

  it "keeps editable user metadata string-typed to avoid double encoding" do
    expect(
      User.get_custom_field_descriptor(described_class::FIELD_NAME).type
    ).to eq(:string)
  end

  describe ".set" do
    it "persists a canonical payload and its spatial projection" do
      location = {
        lat: "51.5074",
        lon: "-0.1278",
        address: "London, United Kingdom",
        city: "London",
        countrycode: "gb"
      }

      described_class.set(user:, location:)

      user.reload
      raw_location =
        UserCustomField.find_by!(user:, name: described_class::FIELD_NAME).value
      expect(JSON.parse(raw_location)).to eq(location.stringify_keys)
      expect(user.custom_fields["geo_location"]).to eq(
        location.stringify_keys.to_json
      )
      expect(described_class.fetch(user)).to eq(location.stringify_keys)
      expect(Locations::UserLocation.find_by(user:)).to have_attributes(
        latitude: 51.5074,
        longitude: -0.1278,
        city: "London",
        countrycode: "gb"
      )
    end
  end

  describe ".sync" do
    it "does not write a projection when the canonical field is absent" do
      queries = track_sql_queries { described_class.sync(user) }

      expect(queries.grep(/DELETE FROM .*locations_user/)).to be_empty
    end

    it "removes a stale projection when the canonical location is cleared" do
      Locations::UserLocation.upsert(
        { user_id: user.id, latitude: 51.5074, longitude: -0.1278 },
        unique_by: :user_id
      )
      user.custom_fields["geo_location"] = ""
      user.save_custom_fields

      described_class.sync(user)

      expect(Locations::UserLocation.exists?(user:)).to eq(false)
    end
  end
end
