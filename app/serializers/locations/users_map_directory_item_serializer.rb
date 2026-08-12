# frozen_string_literal: true

module ::Locations
  class UsersMapDirectoryItemSerializer < ApplicationSerializer
    class UserSerializer < ApplicationSerializer
      attributes :id, :username, :name, :avatar_template, :geo_location

      def include_name?
        SiteSetting.enable_names?
      end

      def geo_location
        location =
          Locations.parse_geo_location(object.custom_fields["geo_location"])
        return if !location.is_a?(Hash)

        latitude = location["lat"]
        longitude = location["lon"]
        return if latitude.blank? || longitude.blank?

        { "lat" => latitude, "lon" => longitude }
      end
    end

    has_one :user, embed: :objects, serializer: UserSerializer

    attributes :id

    def id
      object.user_id
    end
  end
end
