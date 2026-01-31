# frozen_string_literal: true

module ::Locations
  class GeoNamesClient
    Rails.logger.info("Locations GeoNamesClient initialized")
    DEFAULT_BASE_URL = "https://secure.geonames.org/"
    CACHE_TTL = 30.days

    def initialize
      @base_url = DEFAULT_BASE_URL
      @username = SiteSetting.location_geonames_username
      Rails.logger.info("Locations GeoNamesClient base_url=#{@base_url}")
    end

    def get_feature(geoname_id)
      return nil if geoname_id.blank? || @username.blank?

      key = cache_key(geoname_id)
      cached = Rails.cache.read(key)
      return cached if cached.present?

      feature = fetch_and_normalize(geoname_id)
      Rails.cache.write(key, feature, expires_in: CACHE_TTL) if feature.present?
      feature
    end

    private

    def cache_key(id)
      "locations:geonames:getJSON:#{id}"
    end

    def fetch_and_normalize(id)
      Rails.logger.info("Locations GeoNames fetch: geoname_id=#{id}")
      url =
        "#{@base_url}getJSON?" +
          URI.encode_www_form(geonameId: id, username: @username, style: "full", formatted: "true")

      body = FinalDestination::HTTP.get(URI(url))
      raw = JSON.parse(body)
      return nil if raw["status"]

      feature = {
        geoname_id: id.to_i,
        name: raw["name"],
        lat: raw["lat"].to_f,
        lon: raw["lng"].to_f,
        fcl: raw["fcl"],
        fcode: raw["fcode"],
        country_code: raw["countryCode"],
        country_name: raw["countryName"],
        admin1: raw["adminName1"],
      }
      Rails.logger.info(
        "Locations GeoNames feature: geoname_id=#{feature[:geoname_id]} fcl=#{feature[:fcl]} fcode=#{feature[:fcode]}",
      )
      feature
    rescue StandardError => e
      Rails.logger.warn("GeoNames lookup failed (#{id}): #{e.message}")
      nil
    end
  end
end
