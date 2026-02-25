# frozen_string_literal: true

module ::Locations
  class UsersMapDirectoryItemSerializer < ApplicationSerializer
    class UserSerializer < ApplicationSerializer
      attributes :id, :username, :name, :avatar_template, :geo_location

      def name
        object&.name
      end

      def include_name?
        SiteSetting.enable_names?
      end

      def avatar_template
        object&.avatar_template
      end

      def geo_location
        geo = Locations.parse_geo_location(object.custom_fields["geo_location"])
        return nil unless geo.is_a?(Hash)

        lat = geo["lat"]
        lon = geo["lon"]
        return nil if lat.blank? || lon.blank?

        { "lat" => lat, "lon" => lon }
      end
    end

    has_one :user, embed: :objects, serializer: UserSerializer

    attributes :id

    def id
      object.user_id
    end
  end
end
