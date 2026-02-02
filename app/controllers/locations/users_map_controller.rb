# frozen_string_literal: true
module ::Locations
  class UsersMapController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    def index
      render json: success_json
    end
  end
end
