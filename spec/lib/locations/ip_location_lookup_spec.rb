# frozen_string_literal: true
require "rails_helper"

describe ::Locations::IpLocationLookup do
  fab!(:user)

  describe ".cooldown_passed?" do
    it "returns true when cooldown is zero" do
      SiteSetting.location_ip_lookup_cooldown_days = 0
      expect(described_class.cooldown_passed?(user)).to eq(true)
    end

    it "returns false when within cooldown window" do
      SiteSetting.location_ip_lookup_cooldown_days = 1
      user.custom_fields[described_class::LAST_LOOKUP_FIELD] = Time.zone.now.iso8601
      user.save_custom_fields(true)

      expect(described_class.cooldown_passed?(user)).to eq(false)
    end
  end

  describe ".should_skip_existing_location?" do
    before { SiteSetting.locations_skip_ip_based_location_update_if_existing = true }

    it "treats empty geo_location object as missing" do
      user.custom_fields["geo_location"] = "{}"
      user.save_custom_fields(true)

      expect(described_class.should_skip_existing_location?(user)).to eq(false)
    end

    it "does not skip when geo_location lacks coordinates" do
      user.custom_fields["geo_location"] = { city: "Paris" }.to_json
      user.save_custom_fields(true)

      expect(described_class.should_skip_existing_location?(user)).to eq(false)
    end

    it "skips when geo_location has coordinates" do
      user.custom_fields["geo_location"] = { lat: 1, lon: 2 }.to_json
      user.save_custom_fields(true)

      expect(described_class.should_skip_existing_location?(user)).to eq(true)
    end
  end
end
