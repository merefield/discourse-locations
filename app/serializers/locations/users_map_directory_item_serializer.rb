# frozen_string_literal: true

module ::Locations
  class UsersMapDirectoryItemSerializer < ApplicationSerializer
    attributes :id, :user

    def id
      object.user_id
    end

    def user
      user = object.user
      payload = {
        id: user.id,
        username: user.username,
        avatar_template: user.avatar_template,
        geo_location: {
          lat: object[:location_latitude],
          lon: object[:location_longitude]
        }
      }
      payload[:name] = user.name if SiteSetting.enable_names?
      payload
    end
  end
end
