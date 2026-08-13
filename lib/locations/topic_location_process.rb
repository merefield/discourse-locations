# frozen_string_literal: true

module ::Locations
  class TopicLocationProcess
    def self.upsert(topic)
      TopicLocationStore.sync(topic)
    end

    def self.delete(topic_id)
      TopicLocationStore.delete(topic_id)
    end

    def self.search_topics_from_topic_location(topic_id, distance)
      topic_location = TopicLocation.find_by(topic_id:)
      return [] if !topic_location&.geocoded?

      topic_location
        .nearbys(
          distance,
          units: :km,
          select_distance: false,
          select_bearing: false
        )
        .joins(:topic)
        .pluck(:topic_id)
    end

    def self.search_topics_from_location(lat, lon, distance)
      return [] if lat.nil? || lon.nil?

      TopicLocation
        .near([lat.to_f, lon.to_f], distance, units: :km)
        .joins(:topic)
        .pluck(:topic_id)
    end

    def self.get_topic_distance_from_location(topic_id, lat, lon)
      topic_location = TopicLocation.find_by(topic_id:)
      return if !topic_location&.geocoded?

      topic_location.distance_to([lat, lon], units: :km)
    end
  end
end
