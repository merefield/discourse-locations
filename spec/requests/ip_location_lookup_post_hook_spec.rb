# frozen_string_literal: true
require "rails_helper"

RSpec.describe "IP location lookup post hook" do
  fab!(:user)
  fab!(:topic) { Fabricate(:topic, user: user) }

  before do
    SiteSetting.location_enabled = true
    SiteSetting.location_users_map = true
    SiteSetting.location_ip_auto_lookup_enabled = true
    SiteSetting.location_geonames_username = "tester"
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("DISCOURSE_MAXMIND_ACCOUNT_ID").and_return("id")
    allow(ENV).to receive(:[]).with("DISCOURSE_MAXMIND_LICENSE_KEY").and_return("key")
  end

  it "falls back to user.ip_address when other ip sources are missing" do
    user.update!(ip_address: IPAddr.new("203.0.113.5"))

    expect_enqueued_with(
      job: ::Jobs::Locations::IpLocationLookup,
      args: { user_id: user.id, ip_address: "203.0.113.5" }
    ) do
      PostCreator.create!(user, raw: "hello", topic_id: topic.id)
    end
  end
end
