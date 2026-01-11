# frozen_string_literal: true

module Locations
  module TopicQueryExtension
    def list_nearby
      create_list(:nearby) do |topics|
        topics.where(id: ::Locations::UserLocationProcess.search_topics_from_user_location(@user.id, SiteSetting.location_nearby_max_distance_km))
        
        # joins("INNER JOIN workflow_states
        #                       ON workflow_states.topic_id = topics.id
        #               INNER JOIN workflows
        #                       ON workflows.id = workflow_states.workflow_id")
      end
    end
  end
end
