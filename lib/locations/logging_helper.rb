# frozen_string_literal: true

module ::Locations
  def self.ip_lookup_log(message)
    return unless SiteSetting.location_ip_lookup_debug_logging

    Rails.logger.warn(message)
  end
end
