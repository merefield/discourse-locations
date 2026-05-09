/* eslint-disable ember/no-observers */
import { computed, observer } from "@ember/object";
import { scheduleOnce } from "@ember/runloop";
import { withPluginApi } from "discourse/lib/plugin-api";
import Composer from "discourse/models/composer";
import NavItem from "discourse/models/nav-item";
import { i18n } from "discourse-i18n";

const NEW_TOPIC_KEY = "new_topic";

function customFieldEnabled(value) {
  return value === true || value === "true" || value === "t" || value === 1;
}

export default {
  name: "location-edits",
  initialize(container) {
    withPluginApi((api) => {
      api.modifyClass("controller:users", {
        pluginId: "locations-plugin",

        loadUsers(params) {
          if (params !== undefined && params.period === "location") {
            return;
          }
          this._super(params);
        },
      });

      api.modifyClass("model:composer", {
        pluginId: "locations-plugin",

        showLocationControls: computed(
          "subtype",
          "categoryId",
          "topicFirstPost",
          "forceLocationControls",
          function () {
            const { categoryId, topicFirstPost } = this;
            const force = this.forceLocationControls;

            if (!topicFirstPost) {
              return false;
            }
            if (force) {
              return true;
            }
            if (categoryId) {
              const category = this.site.categories.findBy("id", categoryId);
              if (
                category &&
                customFieldEnabled(category.custom_fields?.location_enabled)
              ) {
                return true;
              }
            }
            return false;
          }
        ),

        clearState() {
          this._super(...arguments);
          this.set("location", null);
        },

        maybeSetupDefaultLocation() {
          if (!this.draftKey?.startsWith(NEW_TOPIC_KEY)) {
            return;
          }

          if (!this.get("showLocationControls")) {
            if (this.location !== null) {
              this.set("location", null);
            }

            return;
          }

          if (this.location) {
            return;
          }

          const topicDefaultLocation = this.siteSettings.location_topic_default;
          const userGeoLocation = this.user?.custom_fields?.geo_location;

          if (
            topicDefaultLocation === "user" &&
            userGeoLocation &&
            ((typeof userGeoLocation === "string" &&
              userGeoLocation.replaceAll(" ", "") !== "{}") ||
              (typeof userGeoLocation === "object" &&
                Object.keys(userGeoLocation).length !== 0))
          ) {
            this.set("location", {
              geo_location: userGeoLocation,
            });
          }
        },

        _maybeSetupDefaultLocation() {
          this.maybeSetupDefaultLocation();
        },

        _setupDefaultLocation: observer("draftKey", function () {
          this.maybeSetupDefaultLocation();
        }),
      });

      api.modifyClass("component:composer-body", {
        pluginId: "locations-plugin",

        resizeWhenLocationAdded: observer("composer.location", function () {
          this._triggerComposerResized();
        }),

        applyLocationInlineClass: observer(
          "composer.showLocationControls",
          "composer.composeState",
          function () {
            const applyClasses = () => {
              const showLocationControls = this.get(
                "composer.showLocationControls"
              );
              const containerElement = document.querySelector(
                ".composer-fields .title-and-category"
              );

              if (containerElement) {
                // Toggle the "show-location-controls" class based on `showLocationControls`
                if (showLocationControls) {
                  containerElement.classList.add("show-location-controls");
                } else {
                  containerElement.classList.remove("show-location-controls");
                }

                if (showLocationControls) {
                  const anchorElement = this.site.mobileView
                    ? containerElement.querySelector(".title-input")
                    : containerElement;

                  // Move ".composer-controls-location" element to `anchorElement`
                  const locationControl = document.querySelector(
                    ".composer-controls-location"
                  );
                  if (locationControl && anchorElement) {
                    anchorElement.appendChild(locationControl);
                  }
                }

                this._triggerComposerResized();
              }
            };

            scheduleOnce("afterRender", this, applyClasses);
          }
        ),
      });

      const subtypeShowLocation = ["event", "question", "general"];
      api.modifyClass("model:topic", {
        pluginId: "locations-plugin",

        showLocationControls: computed(
          "subtype",
          "category.custom_fields.location_enabled",
          function () {
            const { subtype } = this;
            const categoryEnabled =
              this.category?.custom_fields?.location_enabled;

            return subtypeShowLocation.indexOf(subtype) > -1 || categoryEnabled;
          }
        ),
      });

      // necessary because topic-title plugin outlet only recieves model
      api.modifyClass("controller:topic", {
        pluginId: "locations-plugin",

        setEditingTopicOnModel: observer("editingTopic", function () {
          this.set("model.editingTopic", this.get("editingTopic"));
        }),
      });

      api.modifyClass("component:edit-category-settings", {
        pluginId: "locations-plugin",

        availableViews: computed("category", function () {
          const { category } = this;
          let views = this._super(category);

          if (
            category?.get?.("custom_fields.location_enabled") &&
            this.siteSettings.location_category_map_filter
          ) {
            views.push({ name: i18n("filters.map.label"), value: "map" });
          }

          return views;
        }),
      });

      const mapRoutes = [
        "Map",
        "MapCategory",
        "MapCategoryNone",
        "map-category",
        "map-category-all",
        "map-category-none",
      ];

      mapRoutes.forEach(function (route) {
        if (container.factoryFor(`route:discovery.${route}`)) {
          api.modifyClass(`route:discovery.${route}`, {
            pluginId: "locations-plugin",

            afterModel() {
              this.templateName = "discovery/map";

              return this._super(...arguments);
            },
          });
        }
      });

      const categoryRoutes = ["category", "categoryNone"];

      categoryRoutes.forEach(function (route) {
        api.modifyClass(`route:discovery.${route}`, {
          pluginId: "locations-plugin",

          afterModel(model, transition) {
            if (
              model?.category &&
              this.filter(model.category) === "map" &&
              this.siteSettings.location_category_map_filter
            ) {
              transition.abort();
              return this.replaceWith(
                `/c/${this.Category.slugFor(model.category)}/l/${this.filter(
                  model.category
                )}`
              );
            } else {
              return this._super(...arguments);
            }
          },
        });
      });
    });

    Composer.serializeOnCreate("location");
    Composer.serializeToTopic("location", "topic.location");

    NavItem.reopenClass({
      buildList(category, args) {
        let items = this._super(category, args);

        // Don't show Site Level "/map"
        if (
          typeof category !== "undefined" &&
          category &&
          category.custom_fields?.location_enabled &&
          category.siteSettings.location_category_map_filter
        ) {
          items.push(NavItem.fromText("map", args)); // Show category level "/map" instead
        }

        return items;
      },
    });
  },
};
