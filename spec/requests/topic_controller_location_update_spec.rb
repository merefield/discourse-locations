# frozen_string_literal: true
require "rails_helper"

RSpec.describe TopicsController do
  fab!(:user) { Fabricate(:user, refresh_auto_groups: true) }
  fab!(:category) { Fabricate(:category, custom_fields: { location_enabled: true }) }

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
  end

  describe "#update" do
    fab!(:topic) { Fabricate(:topic, user: user) }
    fab!(:post) { Fabricate(:post, user: user, topic: topic) }

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
  end
end
