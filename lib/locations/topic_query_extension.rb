# frozen_string_literal: true

module Locations
  module TopicQueryExtension
    def list_map
      @options[:per_page] = SiteSetting.location_map_max_topics
      create_list(:map) do |topics|
        topics =
          topics.joins(
            "INNER JOIN locations_topic
                               ON locations_topic.topic_id = topics.id",
          )

        Locations::Map.sorted_list_filters.each do |filter|
          topics = filter[:block].call(topics, @options)
        end

        topics
      end
    end

    def list_nearby
      create_list(:nearby) do |topics|
        nearby_data =
          ::Locations::UserLocationProcess.list_topics_near_user_location(
            @user.id,
            SiteSetting.location_nearby_list_max_distance_km,
          )
        nearby_map =
          nearby_data.to_h do |topic_id, distance, bearing|
            [topic_id, { distance: distance, bearing: bearing }]
          end
        topic_ids = nearby_data.map(&:first)

        distance_case =
          "CASE topics.id #{nearby_map.map { |id, data| "WHEN #{id} THEN #{data[:distance]}" }.join(" ")} END"
        bearing_case =
          "CASE topics.id #{nearby_map.map { |id, data| "WHEN #{id} THEN #{data[:bearing]}" }.join(" ")} END"

        topics
          .where(id: topic_ids)
          .select("topics.*, #{distance_case} AS distance")
          .select("topics.*, #{bearing_case} AS bearing")
          .order("distance ASC")
      end
    end
  end
end
