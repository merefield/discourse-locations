# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Topic map" do
  fab!(:admin)
  fab!(:announcements_category) do
    Fabricate(
      :category_with_definition,
      user: admin,
      name: "Announcements",
      slug: "announcements",
      custom_fields: {
        location_enabled: true,
      },
    )
  end
  fab!(:software_category) do
    Fabricate(
      :category_with_definition,
      user: admin,
      name: "Software",
      slug: "software",
      custom_fields: {
        location_enabled: true,
      },
    )
  end

  let(:topic_map_page) { PageObjects::Pages::TopicMap.new }

  def create_topic_with_location(title:, category:, lat:, lon:)
    topic = Fabricate(:topic, user: admin, category: category, title: title)

    topic.custom_fields["location"] = { "geo_location" => { "lat" => lat.to_s, "lon" => lon.to_s } }
    topic.custom_fields["has_geo_location"] = true
    topic.save_custom_fields(true)

    Locations::TopicLocation.create!(topic: topic, latitude: lat, longitude: lon)
    topic
  end

  before do
    SiteSetting.location_enabled = true
    SiteSetting.location_category_map_filter = true
    SiteSetting.location_map_maker_cluster_enabled = false
    SiteSetting.location_hide_labels = false
    SiteSetting.location_sidebar_menu_map_link = true
    allow_any_instance_of(Locations::TopicLocation).to receive(:geocode)
    allow_any_instance_of(Locations::TopicLocation).to receive(:reverse_geocode)

    announcements_category.set_permissions(everyone: :full)
    announcements_category.save!
    software_category.set_permissions(everyone: :full)
    software_category.save!

    create_topic_with_location(
      title: "Coolest thing you have seen today",
      category: announcements_category,
      lat: 23.13608785,
      lon: -82.34999917,
    )
    create_topic_with_location(
      title: "The Room Appreciation Topic",
      category: software_category,
      lat: 12.9716,
      lon: 77.5946,
    )

    sign_in(admin)
  end

  it "shows markers for the selected category only" do
    announcements_category.update!(default_view: "map")
    topic_map_page.visit_category(announcements_category)

    expect(topic_map_page.has_map?).to eq(true)
    expect(topic_map_page.has_marker_count?(1)).to eq(true)
    expect(topic_map_page.has_topic_tooltip?("Coolest thing you have seen today")).to eq(true)
    expect(topic_map_page.has_no_topic_tooltip?("The Room Appreciation Topic")).to eq(true)
  end

  it "shows the map when visiting a category map filter directly" do
    topic_map_page.visit_category(announcements_category, filter: "map")

    expect(topic_map_page.has_map?).to eq(true)
    expect(topic_map_page.has_marker_count?(1)).to eq(true)
    expect(topic_map_page.has_topic_tooltip?("Coolest thing you have seen today")).to eq(true)
  end

  it "shows markers from multiple categories on the global map" do
    topic_map_page.visit_general

    expect(topic_map_page.has_map?).to eq(true)
    expect(topic_map_page.has_marker_count?(2)).to eq(true)
    expect(topic_map_page.has_topic_tooltip?("Coolest thing you have seen today")).to eq(true)
    expect(topic_map_page.has_topic_tooltip?("The Room Appreciation Topic")).to eq(true)
  end
end
