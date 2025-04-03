import { withPluginApi } from "discourse/lib/plugin-api";
import { default as discourseComputed } from "discourse-common/utils/decorators";
import I18n from "I18n";

const PLUGIN_ID = "locations-plugin";

export default {
  name: "location-map-renderer",
  initialize(container) {
    withPluginApi("0.8.12", (api) => {
      const siteSettings = container.lookup("site-settings:main");
      const currentUser = container.lookup("service:current-user");

      if (siteSettings.location_sidebar_menu_map_link) {
        api.addCommunitySectionLink({
          name: "map",
          route: "discovery.map",
          title: I18n.t("filters.map.title"),
          text: I18n.t("filters.map.label"),
        });
      }

      if (
        siteSettings.location_users_map &&
        siteSettings.enable_user_directory &&
        !(!currentUser && siteSettings.hide_user_profiles_from_public)
      ) {
        api.addCommunitySectionLink({
          name: "users map",
          route: "locations.users-map",
          title: I18n.t("directory.map.title"),
          text: I18n.t("directory.map.title"),
        });
      }

      api.modifyClass("component:user-card-contents", {
        pluginId: PLUGIN_ID,

        @discourseComputed("user")
        hasLocaleOrWebsite(user) {
          return (
            user.geo_location ||
            user.location ||
            user.website_name ||
            this.userTimezone
          );
        },
      });
    });
  },
};
