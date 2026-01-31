# frozen_string_literal: true

module ::Locations
  class IpLocationLookup
    LAST_LOOKUP_FIELD = "geo_location_ip_last_lookup_at"

    def self.cooldown_passed?(user)
      Rails.logger.info("Locations IP cooldown check: user_id=#{user.id}")
      cooldown = SiteSetting.location_ip_lookup_cooldown_days.to_i.days
      return true if cooldown <= 0

      last = parse_time(user.custom_fields[LAST_LOOKUP_FIELD])
      return true if last.blank?

      Time.zone.now - last >= cooldown
    end

    def self.should_skip_existing_location?(user)
      return false unless SiteSetting.locations_skip_ip_based_location_update_if_existing

      existing = Locations.parse_geo_location(user.custom_fields["geo_location"])
      return false if existing.blank?

      existing.is_a?(Hash) ? existing.present? : true
    end

    def self.mark_lookup!(user)
      user.custom_fields[LAST_LOOKUP_FIELD] = Time.zone.now.utc.iso8601
    end

    def self.parse_time(value)
      return nil if value.blank?

      Time.zone.parse(value.to_s)
    rescue StandardError
      nil
    end
  end
end
