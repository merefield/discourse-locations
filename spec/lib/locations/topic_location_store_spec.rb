# frozen_string_literal: true

RSpec.describe Locations::TopicLocationStore do
  fab!(:topic)

  it "registers the canonical topic location as JSON metadata" do
    expect(
      Topic.get_custom_field_descriptor(described_class::FIELD_NAME).type
    ).to eq(:json)
  end

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
      topic.custom_fields["has_geo_location"] = true
      Locations::TopicLocation.upsert(
        { topic_id: topic.id, latitude: 51.5074, longitude: -0.1278 },
        unique_by: :topic_id
      )

      described_class.assign(topic:, location: { raw: "Somewhere" })
      topic.save_custom_fields

      expect(described_class.fetch(topic.reload)).to eq("raw" => "Somewhere")
      expect(topic.custom_fields).not_to have_key("has_geo_location")
      expect(Locations::TopicLocation.exists?(topic:)).to eq(false)
    end
  end

  describe ".sync" do
    it "does not write a projection when the canonical field is absent" do
      queries = track_sql_queries { described_class.sync(topic) }

      expect(queries.grep(/DELETE FROM .*locations_topic/)).to be_empty
    end
  end
end
