# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DirectoryItemsController do
  fab!(:user) do
    token = SecureRandom.hex(6)
    Fabricate(:user, email: "dir-items-#{token}@example.com", username: "diritems#{token}")
  end

  context "browsing the users map" do
    before(:each) do
      SiteSetting.location_enabled = true
      sign_in(user)
    end
    it "allows user to browse the users map" do
      SiteSetting.location_users_map = true
      SiteSetting.enable_user_directory = true
      get "/directory_items.json?period=location"
      expect(response.status).to eq(200)
    end
    it "doesn't allow user to browse the users map when user directory is disabled" do
      SiteSetting.location_users_map = true
      SiteSetting.enable_user_directory = false
      get "/directory_items.json?period=location"
      expect(response.status).to eq(403)
      expect(response.parsed_body["error_type"]).to eq("invalid_access")
    end
    it "doesn't allow user to browse the users map when user map is disabled" do
      SiteSetting.location_users_map = false
      SiteSetting.enable_user_directory = true
      get "/directory_items.json?period=location"
      expect(response.status).to eq(403)
      expect(response.parsed_body["error_type"]).to eq("invalid_access")
    end
  end
  context "when the plugin is enabled but the user is not logged in" do
    before do
      SiteSetting.location_users_map = true
      SiteSetting.enable_user_directory = true
      SiteSetting.hide_user_profiles_from_public = true
    end
    it "doesn't allow user to browse the users map when the plugin is enabled but the user is not logged in" do
      sign_out
      get "/directory_items.json?period=location"
      expect(response.status).to eq(403)
      expect(response.parsed_body["error_type"]).to eq("invalid_access")
    end
  end
end
