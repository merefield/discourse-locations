# frozen_string_literal: true

require "rails_helper"

RSpec.describe Locations::TopicQueryExtension do
  fab!(:user)
  fab!(:mapped_topic) { Fabricate(:topic, user: user) }
  fab!(:unmapped_topic) { Fabricate(:topic, user: user) }

  describe "#list_map" do
    it "returns only topics in the locations table" do
      Locations::TopicLocation.upsert(
        { topic_id: mapped_topic.id, latitude: 51.5074, longitude: -0.1278 },
        unique_by: :topic_id
      )

      list = TopicQuery.new(user).list_map

      expect(list.topics).to contain_exactly(mapped_topic)
    end
  end
end
