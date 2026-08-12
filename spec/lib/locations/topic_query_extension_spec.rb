# frozen_string_literal: true

require "rails_helper"

RSpec.describe Locations::TopicQueryExtension do
  fab!(:user)
  fab!(:mapped_topic) { Fabricate(:topic, user: user) }
  fab!(:unmapped_topic) { Fabricate(:topic, user: user) }

  describe "#list_map" do
    it "returns only topics in the locations table" do
      Locations::TopicLocation.insert_all!(
        [
          {
            topic_id: mapped_topic.id,
            latitude: 51.5074,
            longitude: -0.1278,
            created_at: Time.zone.now,
            updated_at: Time.zone.now
          }
        ]
      )

      list = TopicQuery.new(user).list_map

      expect(list.topics).to contain_exactly(mapped_topic)
    end

    it "limits the number of mapped topics" do
      SiteSetting.location_map_max_topics = 2
      mapped_topics = 3.times.map { Fabricate(:topic, user: user) }
      timestamp = Time.zone.now
      Locations::TopicLocation.insert_all!(
        mapped_topics.map do |topic|
          {
            topic_id: topic.id,
            latitude: 51.5074,
            longitude: -0.1278,
            created_at: timestamp,
            updated_at: timestamp
          }
        end
      )

      list = TopicQuery.new(user).list_map

      expect(list.topics.length).to eq(2)
      expect(list.topics).to all(
        satisfy { |topic| mapped_topics.include?(topic) }
      )
    end

    it "applies the global closed-topic filter" do
      SiteSetting.location_map_filter_closed = true
      open_topic = Fabricate(:topic, user: user)
      closed_topic = Fabricate(:topic, user: user, closed: true)
      timestamp = Time.zone.now
      Locations::TopicLocation.insert_all!(
        [open_topic, closed_topic].map do |topic|
          {
            topic_id: topic.id,
            latitude: 51.5074,
            longitude: -0.1278,
            created_at: timestamp,
            updated_at: timestamp
          }
        end
      )

      list = TopicQuery.new(user).list_map

      expect(list.topics).to contain_exactly(open_topic)
    end

    it "applies the category closed-topic filter" do
      category =
        Fabricate(
          :category,
          custom_fields: {
            "location_map_filter_closed" => true
          }
        )
      open_topic = Fabricate(:topic, user: user, category: category)
      closed_topic =
        Fabricate(:topic, user: user, category: category, closed: true)
      timestamp = Time.zone.now
      Locations::TopicLocation.insert_all!(
        [open_topic, closed_topic].map do |topic|
          {
            topic_id: topic.id,
            latitude: 51.5074,
            longitude: -0.1278,
            created_at: timestamp,
            updated_at: timestamp
          }
        end
      )

      list = TopicQuery.new(user, category: category.id).list_map

      expect(list.topics).to contain_exactly(open_topic)
    end
  end
end
