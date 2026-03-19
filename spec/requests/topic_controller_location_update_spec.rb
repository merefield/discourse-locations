# frozen_string_literal: true
require "rails_helper"

RSpec.describe TopicsController do
  fab!(:user) { Fabricate(:user, refresh_auto_groups: true) }
  fab!(:category) { Fabricate(:category, user: user, custom_fields: { location_enabled: true }) }
  fab!(:category_without_locations) { Fabricate(:category, user: user) }

  before do
    sign_in(user)
    SiteSetting.location_enabled = true
  end

  describe "#create" do
    it "should create topic with custom fields and create TopicLocation" do
      post "/posts.json",
           params: {
             raw: "this is the test content",
             title: "this is the test title for the topic",
             category: category.id,
             location: {
               geo_location: {
                 lat: 10,
                 lon: 12,
               },
             },
           }
      expect(response.status).to eq(200)

      result = response.parsed_body
      topic = Topic.find(result["topic_id"])

      expect(topic.custom_fields).to eq(
        {
          "has_geo_location" => true,
          "location" => {
            "geo_location" => {
              "lat" => "10",
              "lon" => "12",
            },
          },
        },
      )
      expect(::Locations::TopicLocation.find_by(topic: topic)).to be_present
    end

    it "ignores topic locations for categories without locations enabled" do
      post "/posts.json",
           params: {
             raw: "this is the test content",
             title: "this is the test title for the topic",
             category: category_without_locations.id,
             location: {
               geo_location: {
                 lat: 10,
                 lon: 12,
               },
             },
           }

      expect(response.status).to eq(200)

      result = response.parsed_body
      topic = Topic.find(result["topic_id"])

      expect(topic.custom_fields["location"]).to be_blank
      expect(topic.custom_fields["has_geo_location"]).to be_blank
      expect(::Locations::TopicLocation.find_by(topic: topic)).to be_blank
    end
  end

  describe "#update" do
    fab!(:topic) { Fabricate(:topic, user: user, category: category) }
    fab!(:post) { Fabricate(:post, user: user, topic: topic) }
    fab!(:topic_without_locations) do
      Fabricate(:topic, user: user, category: category_without_locations)
    end
    fab!(:post_without_locations) { Fabricate(:post, user: user, topic: topic_without_locations) }

    it "should update topic with custom fields and create TopicLocation" do
      put "/t/#{topic.id}.json", params: { location: { geo_location: { lat: 10, lon: 12 } } }

      expect(response.status).to eq(200)

      topic.reload
      expect(topic.custom_fields).to eq(
        {
          "has_geo_location" => true,
          "location" => {
            "geo_location" => {
              "lat" => "10",
              "lon" => "12",
            },
          },
        },
      )
      expect(::Locations::TopicLocation.find_by(topic: topic)).to be_present
    end

    it "ignores location updates for categories without locations enabled" do
      put "/t/#{topic_without_locations.id}.json",
          params: {
            location: {
              geo_location: {
                lat: 10,
                lon: 12,
              },
            },
          }

      expect(response.status).to eq(200)

      topic_without_locations.reload
      expect(topic_without_locations.custom_fields["location"]).to be_blank
      expect(topic_without_locations.custom_fields["has_geo_location"]).to be_blank
      expect(::Locations::TopicLocation.find_by(topic: topic_without_locations)).to be_blank
    end
  end
end
