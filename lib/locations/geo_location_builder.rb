# frozen_string_literal: true

module ::Locations
  class GeoLocationBuilder
    def self.from_ip_info(ip_info, granularity:)
      Rails.logger.info(
        "Locations GeoLocationBuilder: granularity=#{granularity} ip_info=#{ip_info.inspect}",
      )
      ids = ip_info[:geoname_ids] || ip_info["geoname_ids"]
      chosen = GeoNamesGranularityPicker.pick(ids, granularity: granularity)
      return nil unless chosen

      country = chosen[:country_name] || ip_info[:country] || ip_info["country"]

      state =
        if granularity == "province"
          chosen[:name]
        elsif granularity == "county"
          chosen[:name]
        elsif granularity == "city"
          chosen[:admin1]
        end

      city = granularity == "city" ? chosen[:name] : nil

      country_code = chosen[:country_code] || ip_info[:country_code] || ip_info["country_code"]

      {
        "lat" => chosen[:lat],
        "lon" => chosen[:lon],
        "address" => [city, state, country].compact.join(", "),
        "countrycode" => country_code&.downcase,
        "city" => city,
        "state" => state,
        "country" => country,
        "postalcode" => nil,
        "boundingbox" => nil,
        "type" => granularity,
        "geoAttrs" => {
          "source" => "maxmind+geonames",
          "granularity" => granularity,
          "geoname_id" => chosen[:geoname_id],
          "fcl" => chosen[:fcl],
          "fcode" => chosen[:fcode],
        },
        "showType" => false,
        "id" => "geoname:#{chosen[:geoname_id]}",
      }
    end
  end
end
