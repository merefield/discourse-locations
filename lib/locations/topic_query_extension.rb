# frozen_string_literal: true

module ::Locations
  module TopicQueryExtension
    def list_map
      @options[:per_page] = SiteSetting.location_map_max_topics
      create_list(:map) do |topics|
        topics =
          topics.joins(
            "INNER JOIN locations_topic ON locations_topic.topic_id = topics.id"
          )

        Locations::Map.sorted_list_filters.each do |filter|
          topics = filter[:block].call(topics, @options)
        end

        topics
      end
    end
  end
end
