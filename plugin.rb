# frozen_string_literal: true
# name: discourse-locations
# about: Tools for handling locations in Discourse
# version: 7.1.5
# authors: Robert Barrow, Angus McLeod
# contact_emails: merefield@gmail.com
# url: https://github.com/merefield/discourse-locations

enabled_site_setting :location_enabled

module ::Locations
  PLUGIN_NAME = "discourse-locations"
end

require_relative "lib/locations/engine"

register_asset "stylesheets/common/locations.scss"
register_asset "stylesheets/desktop/locations.scss", :desktop
register_asset "stylesheets/mobile/locations.scss", :mobile
register_asset "lib/leaflet/leaflet.css"
register_asset "lib/leaflet/leaflet.js"
register_asset "lib/leaflet/leaflet.markercluster.js"
register_asset "lib/leaflet/MarkerCluster.css"
register_asset "lib/leaflet/MarkerCluster.Default.css"

Discourse.top_menu_items.push(:map)
Discourse.anonymous_top_menu_items.push(:map)
Discourse.filters.push(:map)
Discourse.anonymous_filters.push(:map)

gem "geocoder", "1.8.6"

if respond_to?(:register_svg_icon)
  register_svg_icon "far-map"
  register_svg_icon "info"
  register_svg_icon "expand"
end

after_initialize do
  # /lib/locations is autoloaded
  %w[
    app/models/location_country_default_site_setting
    app/models/location_geocoding_language_site_setting
    app/models/locations/user_location
    app/models/locations/topic_location
    app/serializers/locations/geo_location_serializer
    app/serializers/locations/users_map_directory_item_serializer
    app/controllers/locations/geocode_controller
    app/controllers/locations/users_map_controller
    lib/locations/logging_helper
    lib/users_map
  ].each { |path| require_relative path }

  reloadable_patch do
    ListController.prepend(Locations::ListControllerExtension)
    TopicQuery.prepend(Locations::TopicQueryExtension)
  end

  def Locations.parse_geo_location(val)
    return nil if val.blank? || val == "{}"
    return val if val.is_a?(Hash)

    val.is_a?(String) ? JSON.parse(val) : nil
  rescue JSON::ParserError
    nil
  end

  def Locations.ip_auto_lookup_mode
    SiteSetting.location_ip_auto_lookup_mode
  end

  def Locations.ip_auto_lookup_enabled?
    SiteSetting.location_enabled && SiteSetting.location_users_map &&
      ip_auto_lookup_mode != "disabled"
  end

  def Locations.ip_auto_lookup_on_post?
    %w[posting login_and_posting].include?(ip_auto_lookup_mode)
  end

  def Locations.ip_auto_lookup_on_login?
    ip_auto_lookup_mode == "login_and_posting"
  end

  def Locations.latest_login_ip(user)
    user.user_auth_tokens.order(created_at: :desc).pick(:client_ip).presence || user.ip_address
  end

  def Locations.enqueue_ip_lookup(user, ip_address)
    return if user.blank? || ip_address.blank?

    Jobs.enqueue(::Jobs::Locations::IpLocationLookup, user_id: user.id, ip_address: ip_address.to_s)
  end

  Discourse.top_menu_items.push(:nearby)
  Discourse.filters.push(:nearby)

  Category.register_custom_field_type("location", :json)
  Category.register_custom_field_type("location_enabled", :boolean)
  Category.register_custom_field_type("location_topic_status", :boolean)
  Category.register_custom_field_type("location_map_filter_closed", :boolean)

  add_to_class(:category, :location) do
    if self.custom_fields["location"]
      if self.custom_fields["location"].is_a?(String)
        begin
          JSON.parse(self.custom_fields["location"])
        rescue JSON::ParserError => e
          puts e.message
        end
      elsif self.custom_fields["location"].is_a?(Hash)
        self.custom_fields["location"]
      else
        nil
      end
    else
      nil
    end
  end

  module LocationsSiteSettingExtension
    def type_hash(name)
      if name == :top_menu
        @choices[name].push("map") if @choices[name].exclude?("map")
      end
      super(name)
    end
  end

  require_dependency "site_settings/type_supervisor"
  class SiteSettings::TypeSupervisor
    prepend LocationsSiteSettingExtension
  end

  %w[location location_enabled location_topic_status location_map_filter_closed].each do |key|
    if Site.respond_to? :preloaded_category_custom_fields
      Site.preloaded_category_custom_fields << key
    end
  end

  Topic.register_custom_field_type("location", :json)
  Topic.register_custom_field_type("has_geo_location", :boolean)
  add_to_class(:topic, :location) { self.custom_fields["location"] }
  add_preloaded_topic_list_custom_field("location")

  add_to_serializer(
    :topic_view,
    :location,
    include_condition: -> { object.topic.location.present? },
  ) { object.topic.location }

  TopicList.preloaded_custom_fields << "location" if TopicList.respond_to? :preloaded_custom_fields

  add_to_class(:topic, :distance) { self[:distance] }

  add_to_class(:topic, :distance=) { |val| self[:distance] = val }

  add_to_class(:topic, :bearing) { self[:bearing] }

  add_to_class(:topic, :bearing=) { |val| self[:bearing] = val }

  add_to_serializer(
    :topic_list_item,
    :location,
    include_condition: -> { object.location.present? },
  ) { object.location }

  add_to_serializer(
    :topic_list_item,
    :bearing,
    include_condition: -> { object.bearing.present? },
  ) { object.bearing.to_f % 360 }

  add_to_serializer(
    :topic_list_item,
    :distance,
    include_condition: -> { object.distance.present? },
  ) { object.distance.to_f }

  if defined?(register_editable_user_custom_field)
    register_editable_user_custom_field("geo_location")
  end

  User.preloaded_custom_fields << "geo_location" if User.respond_to? :preloaded_custom_fields

  add_to_serializer(:user, :geo_location, respect_plugin_enabled: false) do
    Locations.parse_geo_location(object.custom_fields["geo_location"])
  end

  add_to_serializer(
    :user_card,
    :geo_location,
    include_condition: -> do
      Locations.parse_geo_location(object.custom_fields["geo_location"]).present?
    end,
  ) { Locations.parse_geo_location(object.custom_fields["geo_location"]) }

  add_to_serializer(:post, :user_custom_fields, respect_plugin_enabled: false) do
    public_keys = SiteSetting.public_user_custom_fields.split("|")
    user_fields = object.user&.custom_fields || {}

    out = {}
    public_keys.each do |k|
      v = user_fields[k]
      out[k] = (k == "geo_location" ? Locations.parse_geo_location(v) : v)
    end

    out
  end

  require_dependency "directory_item_serializer"
  class ::DirectoryItemSerializer::UserSerializer
    attributes :geo_location

    def geo_location
      Locations.parse_geo_location(object.custom_fields["geo_location"])
    end

    def include_geo_location?
      SiteSetting.location_users_map
    end
  end

  public_user_custom_fields = SiteSetting.public_user_custom_fields.split("|")
  if public_user_custom_fields.exclude?("geo_location")
    public_user_custom_fields.push("geo_location")
  end
  SiteSetting.public_user_custom_fields = public_user_custom_fields.join("|")

  if SiteSetting.location_ip_auto_lookup_enabled &&
       SiteSetting.location_ip_auto_lookup_mode == "disabled"
    SiteSetting.location_ip_auto_lookup_mode = "posting"
    SiteSetting.location_ip_auto_lookup_enabled = false
  end

  PostRevisor.track_topic_field(:location) do |tc, location|
    if location.present? && location = Locations::Helper.parse_location(location.to_unsafe_hash)
      tc.record_change("location", tc.topic.custom_fields["location"], location)
      tc.topic.custom_fields["location"] = location
      tc.topic.custom_fields["has_geo_location"] = location["geo_location"].present?

      Locations::TopicLocationProcess.upsert(tc.topic)
    else
      tc.topic.custom_fields["location"] = {}
      tc.topic.custom_fields["has_geo_location"] = false
    end
  end

  on(:post_created) do |post, opts, user|
    if post.is_first_post? && opts[:location].present? &&
         location = Locations::Helper.parse_location(opts[:location])
      topic = post.topic
      topic.custom_fields["location"] = location
      topic.custom_fields["has_geo_location"] = location["geo_location"].present?
      topic.save!
      Locations::TopicLocationProcess.upsert(topic)
    end

    next unless Locations.ip_auto_lookup_enabled?
    next unless Locations.ip_auto_lookup_on_post?
    next if user.blank?

    ip_address =
      opts[:ip_address].presence ||
        (post.respond_to?(:ip_address) ? post.ip_address : nil).presence || user.ip_address

    ip_address = "2.139.231.7" if Rails.env.development?

    Locations.enqueue_ip_lookup(user, ip_address)
  end

  on(:user_logged_in) do |user|
    next unless Locations.ip_auto_lookup_enabled?
    next unless Locations.ip_auto_lookup_on_login?
    next if user.blank?

    ip_address = Locations.latest_login_ip(user)
    ip_address = "2.139.231.7" if Rails.env.development?

    Locations.enqueue_ip_lookup(user, ip_address)
  end

  # check latitude and longitude are included when updating users location or raise an error
  register_modifier(:users_controller_update_user_params) do |result, current_user, params|
    raw = params.dig(:custom_fields, :geo_location)
    next result if raw.nil?

    # Clear
    if raw.blank? || raw == {} || raw == "{}"
      result[:custom_fields] ||= {}
      result[:custom_fields][:geo_location] = ""
      next result
    end

    json_string =
      case raw
      when String
        raw
      when Hash, ActionController::Parameters
        raw.to_h.to_json
      else
        raw.to_s
      end

    value_hash =
      begin
        JSON.parse(json_string)
      rescue StandardError
        nil
      end
    unless value_hash.is_a?(Hash) && value_hash["lat"].present? && value_hash["lon"].present?
      raise Discourse::InvalidParameters.new, I18n.t("location.errors.invalid")
    end

    result[:custom_fields] ||= {}
    result[:custom_fields][:geo_location] = json_string

    result
  end

  on(:user_updated) do |*params|
    user_id = params[0].id

    Locations::UserLocationProcess.upsert(user_id) if SiteSetting.location_enabled
  end

  on(:user_destroyed) do |*params|
    user_id = params[0].id

    Locations::UserLocationProcess.delete(user_id)
  end

  class ::Jobs::AnonymizeUser
    module LocationsEdits
      def make_anonymous
        super
        ::Locations::UserLocationProcess.delete(@user_id)
      end
    end
    prepend LocationsEdits
  end

  unless Rails.env.test?
    begin
      Locations::Geocode.set_config
    rescue StandardError
      Locations::Geocode.revert_to_default_provider
    end

    # To be removed
    if SiteSetting.location_geocoding_provider == "mapzen"
      Locations::Geocode.revert_to_default_provider
    end
  end

  add_model_callback(SiteSetting, :before_save) do
    Locations::Geocode.set_config(provider: value) if name == "location_geocoding_provider"
    Locations::Geocode.set_config(timeout: value) if name == "location_geocoding_timeout"
  end

  add_to_class(:site, :country_codes) { @country_codes ||= Locations::Country.codes }

  add_to_serializer(:site, :country_codes, respect_plugin_enabled: false) { object.country_codes }

  require_dependency "topic_query"

  Locations::Map.add_list_filter do |topics, options|
    category = Category.find(options[:category_id]) if options[:category_id]

    if SiteSetting.location_map_filter_closed ||
         (options[:category_id] && category.custom_fields["location_map_filter_closed"])
      topics = topics.where(closed: false)
    end

    topics
  end

  DiscourseEvent.trigger(:locations_ready)
end

on(:custom_wizard_ready) do
  if defined?(CustomWizard) == "constant" && CustomWizard.class == Module
    CustomWizard::Field.register("location", "discourse-locations")
    CustomWizard::Action.register_callback(
      :before_create_topic,
    ) do |params, wizard, action, submission|
      if action["add_location"]
        location =
          CustomWizard::Mapper.new(
            inputs: action["add_location"],
            data: submission&.fields_and_meta,
            user: wizard.user,
          ).perform

        if location.present?
          location = Locations::Helper.parse_location(location)

          location_params = {}
          location_params["location"] = location
          location_params["has_geo_location"] = location["geo_location"].present?

          params[:topic_opts] ||= {}
          params[:topic_opts][:custom_fields] ||= {}
          params[:topic_opts][:custom_fields].merge!(location_params)
        end
      end

      params
    end
  end
end
