import { scheduleOnce } from "@ember/runloop";
import { withPluginApi } from "discourse/lib/plugin-api";
import Composer from "discourse/models/composer";
import NavItem from "discourse/models/nav-item";
import {
  default as discourseComputed,
  observes,
} from "discourse-common/utils/decorators";
import I18n from "I18n";

const NEW_TOPIC_KEY = "new_topic";

export default {
  name: "location-edits",
  initialize(container) {
    const siteSettings = container.lookup("site-settings:main");
    const site = container.lookup("site:main");

    withPluginApi("0.8.23", (api) => {
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

        @discourseComputed(
          "subtype",
          "categoryId",
          "topicFirstPost",
          "forceLocationControls"
        )
        showLocationControls(subtype, categoryId, topicFirstPost, force) {
          if (!topicFirstPost) {
            return false;
          }
          if (force) {
            return true;
          }
          if (categoryId) {
            const category = this.site.categories.findBy("id", categoryId);
            if (category && category.custom_fields?.location_enabled) {
              return true;
            }
          }
          return false;
        },

        clearState() {
          this._super(...arguments);
          this.set("location", null);
        },

        @observes("draftKey")
        _setupDefaultLocation() {
          if (this.draftKey.startsWith(NEW_TOPIC_KEY)) {
            const topicDefaultLocation =
              this.siteSettings.location_topic_default;
            // NB: we can't use the siteSettings, nor currentUser values set in the initialiser here
            // because in QUnit they will not be defined as the initialiser only runs once
            // so this will break all tests, even if in runtime it may work.
            // so solution is to use the values provided by the Composer model under 'this'.
            if (
              topicDefaultLocation === "user" &&
              this.user.custom_fields.geo_location &&
              ((typeof this.user.custom_fields.geo_location === "string" &&
                this.user.custom_fields.geo_location.replaceAll(" ", "") !==
                  "{}") ||
                (typeof this.user.custom_fields.geo_location === "object" &&
                  Object.keys(this.user.custom_fields.geo_location).length !==
                    0))
            ) {
              this.set("location", {
                geo_location: this.user.custom_fields.geo_location,
              });
            }
          }
        },
      });

      api.modifyClass("component:composer-body", {
        pluginId: "locations-plugin",

        @observes("composer.location")
        resizeWhenLocationAdded: function () {
          this._triggerComposerResized();
        },

        @observes("composer.showLocationControls", "composer.composeState")
        applyLocationInlineClass() {
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
        },
      });

      const subtypeShowLocation = ["event", "question", "general"];
      api.modifyClass("model:topic", {
        pluginId: "locations-plugin",

        @discourseComputed("subtype", "category.custom_fields.location_enabled")
        showLocationControls(subtype, categoryEnabled) {
          return subtypeShowLocation.indexOf(subtype) > -1 || categoryEnabled;
        },
      });

      // necessary because topic-title plugin outlet only recieves model
      api.modifyClass("controller:topic", {
        pluginId: "locations-plugin",

        @observes("editingTopic")
        setEditingTopicOnModel() {
          this.set("model.editingTopic", this.get("editingTopic"));
        },
      });

      api.modifyClass("component:edit-category-settings", {
        pluginId: "locations-plugin",

        @discourseComputed("category")
        availableViews(category) {
          let views = this._super(...arguments);

          if (
            category.get("custom_fields.location_enabled") &&
            this.siteSettings.location_category_map_filter
          ) {
            views.push({ name: I18n.t("filters.map.label"), value: "map" });
          }

          return views;
        },
      });

      const mapRoutes = [`Map`, `MapCategory`, `MapCategoryNone`];

      mapRoutes.forEach(function (route) {
        api.modifyClass(`route:discovery.${route}`, {
          pluginId: "locations-plugin",

          afterModel() {
            this.templateName = "discovery/map";

            return this._super(...arguments);
          },
        });
      });

      const categoryRoutes = ["category", "categoryNone"];

      categoryRoutes.forEach(function (route) {
        api.modifyClass(`route:discovery.${route}`, {
          pluginId: "locations-plugin",

          afterModel(model, transition) {
            if (
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
