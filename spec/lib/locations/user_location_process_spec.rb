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

  describe ".search_users_from_topic_location" do
    it "returns users near the topic" do
      topic = Fabricate(:topic)
      nearby_user = Fabricate(:user)
      distant_user = Fabricate(:user)
      timestamps = { created_at: Time.zone.now, updated_at: Time.zone.now }

      Locations::TopicLocation.insert_all!(
        [
          {
            topic_id: topic.id,
            latitude: 51.5074,
            longitude: -0.1278,
            **timestamps
          }
        ]
      )
      Locations::UserLocation.insert_all!(
        [
          {
            user_id: nearby_user.id,
            latitude: 51.515,
            longitude: -0.13,
            **timestamps
          },
          {
            user_id: distant_user.id,
            latitude: 40.7128,
            longitude: -74.006,
            **timestamps
          }
        ]
      )

      expect(
        described_class.search_users_from_topic_location(topic.id, 10)
      ).to contain_exactly(nearby_user.id)
    end
  end
end
