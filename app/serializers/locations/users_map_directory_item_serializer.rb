# frozen_string_literal: true

module ::Locations
  class UsersMapDirectoryItemSerializer < ApplicationSerializer
    class UserSerializer < UserNameSerializer
      attributes :geo_location

      def geo_location
        geo = Locations.parse_geo_location(object.custom_fields["geo_location"])
        return nil unless geo.is_a?(Hash)

        lat = geo["lat"]
        lon = geo["lon"]
        return nil unless lat.present? && lon.present?

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
