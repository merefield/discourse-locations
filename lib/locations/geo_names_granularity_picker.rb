# frozen_string_literal: true

module ::Locations
  class GeoNamesGranularityPicker
    CITY_PRIORITY = { "PPLC" => 5, "PPLA" => 4, "PPLA2" => 3, "PPLA3" => 2, "PPL" => 1 }.freeze

    def self.pick(ids, granularity:)
      Rails.logger.info("Locations GeoNames pick: ids=#{ids.inspect} granularity=#{granularity}")
      client = GeoNamesClient.new
      features = Array(ids).uniq.filter_map { |id| client.get_feature(id) }

      country = features.find { |f| f[:fcl] == "A" && f[:fcode] == "PCLI" }
      admin1 = features.find { |f| f[:fcl] == "A" && f[:fcode] == "ADM1" }
      city =
        features
          .select { |f| f[:fcl] == "P" && f[:fcode].start_with?("PPL") }
          .max_by { |f| CITY_PRIORITY.fetch(f[:fcode], 0) }

      Rails.logger.info(
        "Locations GeoNames pick result: country=#{country&.dig(:geoname_id)} admin1=#{admin1&.dig(:geoname_id)} city=#{city&.dig(:geoname_id)}",
      )

      case granularity
      when "country"
        country
      when "province"
        admin1 || country
      when "city"
        city || admin1 || country
      else
        nil
      end
    end
  end
end
