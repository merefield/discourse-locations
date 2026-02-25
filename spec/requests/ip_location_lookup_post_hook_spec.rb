# frozen_string_literal: true
require "rails_helper"

RSpec.describe "IP location lookup hooks" do
  fab!(:user)
  fab!(:topic) { Fabricate(:topic, user: user) }

  before do
    SiteSetting.location_enabled = true
    SiteSetting.location_users_map = true
  end

  describe "post-created hook" do
    before { SiteSetting.location_ip_auto_lookup_mode = "posting" }

    it "falls back to user.ip_address when other ip sources are missing" do
      user.update!(ip_address: IPAddr.new("203.0.113.5"))

      expect_enqueued_with(
        job: ::Jobs::Locations::IpLocationLookup,
        args: {
          user_id: user.id,
          ip_address: "203.0.113.5",
        },
      ) { PostCreator.create!(user, raw: "hello", topic_id: topic.id) }
    end

    it "does not enqueue when mode is disabled" do
      SiteSetting.location_ip_auto_lookup_mode = "disabled"
      user.update!(ip_address: IPAddr.new("203.0.113.6"))

      expect_not_enqueued_with(job: ::Jobs::Locations::IpLocationLookup) do
        PostCreator.create!(user, raw: "hello", topic_id: topic.id)
      end
    end
  end

  describe "user-logged-in hook" do
    before { SiteSetting.location_ip_auto_lookup_mode = "login_and_posting" }

    it "uses the latest auth token client_ip when a user logs in" do
      UserAuthToken.generate!(
        user_id: user.id,
        user_agent: "RSpec",
        client_ip: "198.51.100.10",
        path: "/login",
      )

      expect_enqueued_with(
        job: ::Jobs::Locations::IpLocationLookup,
        args: {
          user_id: user.id,
          ip_address: "198.51.100.10",
        },
      ) { user.logged_in }
    end

    it "does not enqueue on login when mode is posting-only" do
      SiteSetting.location_ip_auto_lookup_mode = "posting"

      UserAuthToken.generate!(
        user_id: user.id,
        user_agent: "RSpec",
        client_ip: "198.51.100.11",
        path: "/login",
      )

      expect_not_enqueued_with(job: ::Jobs::Locations::IpLocationLookup) { user.logged_in }
    end
  end
end
