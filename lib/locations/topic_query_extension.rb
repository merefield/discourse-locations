# frozen_string_literal: true

module Locations
  module TopicQueryExtension
    def list_nearby
      create_list(:nearby) do |topics|
        nearby_data = ::Locations::UserLocationProcess.list_topics_near_user_location(@user.id, SiteSetting.location_nearby_list_max_distance_km)
        nearby_map = nearby_data.to_h { |topic_id, distance, bearing| [topic_id, { distance: distance, bearing: bearing }] }
        topic_ids = nearby_data.map(&:first)

        distance_case =
          "CASE topics.id #{nearby_map.map { |id, data| "WHEN #{id} THEN #{data[:distance]}" }.join(' ')} END"
        bearing_case =
          "CASE topics.id #{nearby_map.map { |id, data| "WHEN #{id} THEN #{data[:bearing]}" }.join(' ')} END"

        topics
          .where(id: topic_ids)
          .select("topics.*, #{distance_case} AS distance")
          .select("topics.*, #{bearing_case} AS bearing")
          .order("distance ASC")
      end
    end
  end
end
