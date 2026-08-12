# frozen_string_literal: true

module ::Locations
  class UserLocationProcess
    def self.upsert(user_id)
      user = User.find_by(id: user_id)
      geo_location =
        Locations.parse_geo_location(user&.custom_fields&.[]("geo_location"))

      if user.nil? || !geo_location.is_a?(Hash) || geo_location["lat"].blank? ||
           geo_location["lon"].blank?
        return
      end

      ::Locations::UserLocation.upsert(
        {
          user_id: user_id,
          latitude: geo_location["lat"],
          longitude: geo_location["lon"],
          street: geo_location["street"],
          district: geo_location["district"],
          city: geo_location["city"],
          state: geo_location["state"],
          postalcode: geo_location["postalcode"],
          country: geo_location["country"],
          countrycode: geo_location["countrycode"],
          international_code: geo_location["international_code"],
          locationtype: geo_location["type"],
          boundingbox: geo_location["boundingbox"]
        },
        on_duplicate: :update,
        unique_by: :user_id
      )
    end

    def self.delete(user_id)
      location = ::Locations::UserLocation.find_by(user_id: user_id)
      location.delete if location
    end

    def self.search_users_from_user_location(user_id, distance)
      user_location = UserLocation.find_by(user_id: user_id)

      return [] if !user_location || !user_location.geocoded?

      user_location
        .nearbys(
          distance,
          units: :km,
          select_distance: false,
          select_bearing: false
        )
        .joins(:user)
        .pluck(:user_id)
    end

    def self.search_users_from_location(lat, lon, distance)
      return [] if lat.nil? || lon.nil?

      UserLocation
        .near(
          [lat.to_f, lon.to_f],
          distance.to_f,
          units: :km,
          select_distance: false,
          select_bearing: false
        )
        .joins(:user)
        .pluck(:user_id)
    end

    def self.get_user_distance_from_location(user_id, lat, lon)
      user_location = UserLocation.find_by(user_id: user_id)

      return nil if !user_location || !user_location.geocoded?

      user_location.distance_to([lat, lon], :km)
    end

    def self.search_topics_from_user_location(user_id, distance)
      user_location = UserLocation.find_by(user_id: user_id)

      return [] if !user_location || !user_location.geocoded?

      TopicLocation
        .near(
          [user_location.latitude, user_location.longitude],
          distance,
          units: :km,
          select_distance: false,
          select_bearing: false
        )
        .joins(:topic)
        .pluck(:topic_id)
    end

    def self.search_users_from_topic_location(topic_id, distance)
      topic_location = TopicLocation.find_by(user_id: topic_id)

      return [] if !topic_location || !topic_location.geocoded?

      UserLocation
        .near(
          [topic_location.latitude, topic_location.longitude],
          distance,
          units: :km,
          select_distance: false,
          select_bearing: false
        )
        .joins(:user)
        .pluck(:user_id)
    end
  end
end
