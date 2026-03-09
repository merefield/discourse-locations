# frozen_string_literal: true
require "rails_helper"

describe ::Locations::LoggingHelper do
  describe ".ip_lookup_log" do
    it "logs when debug logging is enabled" do
      SiteSetting.location_ip_lookup_debug_logging = true

      allow(Rails.logger).to receive(:warn)

      described_class.ip_lookup_log("hello")

      expect(Rails.logger).to have_received(:warn).with("hello")
    end

    it "does not log when debug logging is disabled" do
      SiteSetting.location_ip_lookup_debug_logging = false

      allow(Rails.logger).to receive(:warn)

      described_class.ip_lookup_log("hello")

      expect(Rails.logger).not_to have_received(:warn)
    end
  end
end
