# frozen_string_literal: true

RSpec.describe Locations::ProjectionReconciler do
  fab!(:user)
  fab!(:topic)

  it "creates missing spatial projections from canonical locations" do
    user.custom_fields["geo_location"] = { lat: 51.5074, lon: -0.1278 }.to_json
    user.save_custom_fields
    topic.custom_fields["location"] = {
      geo_location: {
        lat: 48.8566,
        lon: 2.3522
      }
    }
    topic.save_custom_fields

    described_class.reconcile

    expect(Locations::UserLocation.find_by(user:)).to have_attributes(
      latitude: 51.5074,
      longitude: -0.1278
    )
    expect(Locations::TopicLocation.find_by(topic:)).to have_attributes(
      latitude: 48.8566,
      longitude: 2.3522
    )
  end

  it "removes projections without canonical locations" do
    Locations::UserLocation.upsert(
      { user_id: user.id, latitude: 51.5074, longitude: -0.1278 },
      unique_by: :user_id
    )
    Locations::TopicLocation.upsert(
      { topic_id: topic.id, latitude: 48.8566, longitude: 2.3522 },
      unique_by: :topic_id
    )

    described_class.reconcile

    expect(Locations::UserLocation.exists?(user:)).to eq(false)
    expect(Locations::TopicLocation.exists?(topic:)).to eq(false)
  end
end
