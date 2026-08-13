# frozen_string_literal: true

RSpec.describe Locations::TopicLocationStore do
  fab!(:topic)

  describe ".assign" do
    it "persists a rich canonical payload and normalized spatial projection" do
      location = {
        raw: "London, United Kingdom",
        name: "London",
        geo_location: {
          lat: "51.5074",
          lon: "-0.1278",
          city: "London",
          countrycode: "gb"
        }
      }

      described_class.assign(topic:, location:)
      topic.save_custom_fields

      expect(described_class.fetch(topic.reload)).to eq(
        location.deep_stringify_keys
      )
      expect(Locations::TopicLocation.find_by(topic:)).to have_attributes(
        latitude: 51.5074,
        longitude: -0.1278,
        name: "London",
        city: "London",
        countrycode: "gb"
      )
    end

    it "retains a textual location while removing its stale spatial projection" do
      Locations::TopicLocation.upsert(
        { topic_id: topic.id, latitude: 51.5074, longitude: -0.1278 },
        unique_by: :topic_id
      )

      described_class.assign(topic:, location: { raw: "Somewhere" })
      topic.save_custom_fields

      expect(described_class.fetch(topic.reload)).to eq("raw" => "Somewhere")
      expect(Locations::TopicLocation.exists?(topic:)).to eq(false)
    end
  end
end
