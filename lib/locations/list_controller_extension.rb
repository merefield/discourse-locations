# frozen_string_literal: true

module Locations
  module ListControllerExtension
    extend ActiveSupport::Concern

    prepended do
      before_action :ensure_discourse_locations, only: %i[nearby]
      skip_before_action :ensure_logged_in, only: %i[nearby]
    end

    def nearby
      list_opts = build_topic_list_options
      user = list_target_user
      list = TopicQuery.new(user, list_opts).public_send("list_nearby")
      list.more_topics_url = url_for(construct_url_with(:next, list_opts))
      list.prev_topics_url = url_for(construct_url_with(:prev, list_opts))
      respond_with_list(list)
    end

    protected

    def ensure_discourse_locations
      if !SiteSetting.location_enabled
        raise Discourse::NotFound
      end
    end
  end
end
