# frozen_string_literal: true
module DirectoryItemsControllerExtension
  def index
    if params[:period] === "location"
      unless SiteSetting.enable_user_directory?
        raise Discourse::InvalidAccess.new(:enable_user_directory)
      end
      unless SiteSetting.location_users_map?
        raise Discourse::InvalidAccess.new(:location_users_map)
      end
      if SiteSetting.hide_user_profiles_from_public? && !current_user
        raise Discourse::InvalidAccess.new(:hide_user_profiles_from_public)
      end

      limit = SiteSetting.location_users_map_limit.to_i

      result =
        DirectoryItem
          .joins(
            "INNER JOIN locations_user ON directory_items.user_id = locations_user.user_id"
          )
          .joins("INNER JOIN users ON users.id = directory_items.user_id")
          .select(
            "directory_items.*",
            "locations_user.latitude AS location_latitude",
            "locations_user.longitude AS location_longitude"
          )
          .where("period_type = 5")
          .includes(:user)
          .order(
            Arel.sql(
              "users.last_seen_at DESC NULLS LAST, directory_items.id ASC"
            )
          )

      query_options =
        DiscoursePluginRegistry.apply_modifier(
          :locations_users_map_query_options,
          { query: result, limit: limit },
          guardian,
          params.to_unsafe_h
        )
      result = query_options.fetch(:query)
      limit = query_options.fetch(:limit)
      if !limit.nil? && (!limit.is_a?(Integer) || limit.negative?)
        raise ArgumentError,
              "locations_users_map_query_options limit must be a non-negative integer or nil"
      end
      result = result.limit(limit) if limit

      serializer_opts = {}
      serializer_opts[:attributes] = []

      serialized =
        serialize_data(
          result,
          Locations::UsersMapDirectoryItemSerializer,
          serializer_opts
        )
      render_json_dump(directory_items: serialized, meta: {})
    else
      super
    end
  end
end

require_dependency "directory_items_controller"
class ::DirectoryItemsController
  prepend DirectoryItemsControllerExtension
end
