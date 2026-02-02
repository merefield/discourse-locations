# frozen_string_literal: true

module ::Jobs
  module Locations
    class IpLocationLookup < ::Jobs::Base
      def execute(args)
        return unless SiteSetting.location_enabled
        return unless SiteSetting.location_users_map
        return if SiteSetting.location_geonames_username.blank?
        return if ENV["DISCOURSE_MAXMIND_ACCOUNT_ID"].blank?
        return if ENV["DISCOURSE_MAXMIND_LICENSE_KEY"].blank?

        ::Locations.ip_lookup_log(
          "1. Locations IP lookup start: user_id=#{args[:user_id]} ip_address=#{args[:ip_address]}",
        )

        user_id = args[:user_id]
        ip_address = args[:ip_address].presence
        return if user_id.blank? || ip_address.blank?

        user = User.find_by(id: user_id)
        return if user.blank?

        return unless ::Locations::IpLocationLookup.cooldown_passed?(user)
        return if ::Locations::IpLocationLookup.should_skip_existing_location?(user)

        ip_info = DiscourseIpInfo.get(ip_address)
        ::Locations.ip_lookup_log(
          "2. Locations IP lookup MaxMind response: user_id=#{user_id} ip_address=#{ip_address} ip_info=#{ip_info.inspect}",
        )
        return if ip_info.blank?

        geo_location =
          ::Locations::GeoLocationBuilder.from_ip_info(
            ip_info,
            granularity: SiteSetting.location_ip_granularity,
          )
        ::Locations.ip_lookup_log(
          "7. Locations IP lookup GeoLocationBuilder result: user_id=#{user_id} ip_address=#{ip_address} geo_location=#{geo_location.inspect}",
        )

        if geo_location.blank?
          ::Locations.ip_lookup_log(
            "7. Locations IP lookup: no geo_location built for user_id=#{user_id} ip_address=#{ip_address}",
          )
          return
        end

        user.custom_fields["geo_location"] = geo_location.to_json
        ::Locations::IpLocationLookup.mark_lookup!(user)
        user.save_custom_fields(true)
        ::Locations.ip_lookup_log(
          "8. Locations IP lookup saved geo_location: user_id=#{user_id} ip_address=#{ip_address}",
        )
        ::Locations::UserLocationProcess.upsert(user.id)
        ::Locations.ip_lookup_log(
          "9. Locations IP lookup updated user_location: user_id=#{user_id} ip_address=#{ip_address}",
        )
      end
    end
  end
end
