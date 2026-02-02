# frozen_string_literal: true

module ::Locations
  class GeoNamesClient
    DEFAULT_BASE_URL = "https://secure.geonames.org/"
    CACHE_TTL = 30.days

    def initialize
      @base_url = DEFAULT_BASE_URL
      @username = SiteSetting.location_geonames_username
      ::Locations.ip_lookup_log("5. Locations GeoNamesClient initialized")
      ::Locations.ip_lookup_log("5. Locations GeoNamesClient base_url=#{@base_url}")
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
      ::Locations.ip_lookup_log("5. Locations GeoNames fetch: geoname_id=#{id}")
      url =
        "#{@base_url}getJSON?" +
          URI.encode_www_form(geonameId: id, username: @username, style: "full", formatted: "true")

      ::Locations.ip_lookup_log("5. Locations GeoNames request: url=#{url}")
      body = FinalDestination::HTTP.get(URI(url))
      ::Locations.ip_lookup_log("5. Locations GeoNames response: geoname_id=#{id} body=#{body}")
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
      ::Locations.ip_lookup_log(
        "5. Locations GeoNames feature: geoname_id=#{feature[:geoname_id]} name=#{feature[:name]} lat=#{feature[:lat]} lon=#{feature[:lon]} fcl=#{feature[:fcl]} fcode=#{feature[:fcode]}",
      )
      feature
    rescue StandardError => e
      ::Locations.ip_lookup_log("5. GeoNames lookup failed (#{id}): #{e.message}")
      nil
    end
  end
end
