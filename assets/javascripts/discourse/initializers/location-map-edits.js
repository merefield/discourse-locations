import { default as discourseComputed } from "discourse/lib/decorators";
import { withPluginApi } from "discourse/lib/plugin-api";
import { i18n } from "discourse-i18n";

const PLUGIN_ID = "locations-plugin";

export default {
  name: "location-map-renderer",
  initialize(container) {
    withPluginApi((api) => {
      const siteSettings = container.lookup("service:site-settings");
      const currentUser = container.lookup("service:current-user");

      if (siteSettings.location_sidebar_menu_map_link) {
        api.addCommunitySectionLink({
          name: "map",
          route: "discovery.map",
          title: i18n("filters.map.title"),
          text: i18n("filters.map.label"),
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
          title: i18n("directory.map.title"),
          text: i18n("directory.map.title"),
        });
      }

      api.modifyClass(
        "component:user-card-contents",
        (Superclass) =>
          class extends Superclass {
            pluginId = PLUGIN_ID;

            @discourseComputed("user")
            hasLocaleOrWebsite(user) {
              return (
                user.geo_location ||
                user.location ||
                user.website_name ||
                this.userTimezone
              );
            }
          }
      );
    });
  },
};
