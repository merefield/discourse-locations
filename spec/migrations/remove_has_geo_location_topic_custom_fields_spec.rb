# frozen_string_literal: true

require_relative "../../db/migrate/20260813114509_remove_has_geo_location_topic_custom_fields"

RSpec.describe RemoveHasGeoLocationTopicCustomFields do
  fab!(:topic)

  it "removes the redundant topic location metadata" do
    TopicCustomField.create!(topic:, name: "has_geo_location", value: "t")
    TopicCustomField.create!(topic:, name: "location_note", value: "keep")

    described_class.new.up

    expect(TopicCustomField.exists?(topic:, name: "has_geo_location")).to eq(
      false
    )
    expect(TopicCustomField.exists?(topic:, name: "location_note")).to eq(true)
  end
end
