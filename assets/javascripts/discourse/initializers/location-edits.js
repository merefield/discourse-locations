/* eslint-disable ember/no-observers */
import { computed } from "@ember/object";
import { next, scheduleOnce } from "@ember/runloop";
import { observes } from "@ember-decorators/object";
import { withPluginApi } from "discourse/lib/plugin-api";
import Composer from "discourse/models/composer";
import NavItem from "discourse/models/nav-item";
import { i18n } from "discourse-i18n";

const NEW_TOPIC_KEY = "new_topic";

function parseGeoLocation(rawGeoLocation) {
  if (!rawGeoLocation || rawGeoLocation === "{}") {
    return null;
  }

  if (typeof rawGeoLocation === "string") {
    if (rawGeoLocation.replaceAll(" ", "") === "{}") {
      return null;
    }

    try {
      rawGeoLocation = JSON.parse(rawGeoLocation);
    } catch {
      return null;
    }
  }

  if (
    typeof rawGeoLocation === "object" &&
    Object.keys(rawGeoLocation).length
  ) {
    return rawGeoLocation;
  }

  return null;
}

function customFieldEnabled(value) {
  return value === true || value === "true" || value === "t" || value === 1;
}

export default {
  name: "location-edits",
  initialize(container) {
    const siteSettings = container.lookup("service:site-settings");

    withPluginApi((api) => {
      api.modifyClass(
        "controller:users",
        (Superclass) =>
          class extends Superclass {
            pluginId = "locations-plugin";

            loadUsers(params) {
              if (params !== undefined && params.period === "location") {
                return;
              }
              super.loadUsers(params);
            }
          }
      );

      api.modifyClass(
        "model:composer",
        (Superclass) =>
          class extends Superclass {
            pluginId = "locations-plugin";

            init() {
              super.init(...arguments);
              this._maybeSetupDefaultLocation();
            }

            @computed(
              "subtype",
              "categoryId",
              "topicFirstPost",
              "forceLocationControls"
            )
            get showLocationControls() {
              const { categoryId, topicFirstPost } = this;
              const force = this.forceLocationControls;

              if (!topicFirstPost) {
                return false;
              }
              if (force) {
                return true;
              }
              if (categoryId) {
                const category = this.site.categories.find(
                  (item) => item.id === categoryId
                );
                if (
                  category &&
                  customFieldEnabled(category.custom_fields?.location_enabled)
                ) {
                  return true;
                }
              }
              return false;
            }

            clearState() {
              super.clearState(...arguments);
              this.set("location", null);
            }

            maybeSetupDefaultLocation() {
              if (!this.draftKey) {
                next(this, this._maybeSetupDefaultLocation);
                return;
              }

              if (!this.draftKey.startsWith(NEW_TOPIC_KEY)) {
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

              const topicDefaultLocation =
                this.siteSettings.location_topic_default;
              const userGeoLocation = parseGeoLocation(
                this.user?.custom_fields?.geo_location
              );

              if (topicDefaultLocation === "user" && userGeoLocation) {
                this.set("location", {
                  geo_location: userGeoLocation,
                });
              }
            }

            _maybeSetupDefaultLocation() {
              this.maybeSetupDefaultLocation();
            }

            @observes("draftKey", "categoryId")
            _setupDefaultLocation() {
              this.maybeSetupDefaultLocation();
            }
          }
      );

      api.modifyClass(
        "component:composer-body",
        (Superclass) =>
          class extends Superclass {
            pluginId = "locations-plugin";

            @observes("composer.location")
            resizeWhenLocationAdded() {
              this._triggerComposerResized();
            }

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
            }
          }
      );

      const subtypeShowLocation = ["event", "question", "general"];
      api.modifyClass(
        "model:topic",
        (Superclass) =>
          class extends Superclass {
            pluginId = "locations-plugin";

            @computed("subtype", "category.custom_fields.location_enabled")
            get showLocationControls() {
              const { subtype } = this;
              const categoryEnabled =
                this.category?.custom_fields?.location_enabled;

              return (
                subtypeShowLocation.indexOf(subtype) > -1 || categoryEnabled
              );
            }
          }
      );

      // necessary because topic-title plugin outlet only recieves model
      api.modifyClass(
        "controller:topic",
        (Superclass) =>
          class extends Superclass {
            pluginId = "locations-plugin";

            @observes("editingTopic")
            setEditingTopicOnModel() {
              this.set("model.editingTopic", this.get("editingTopic"));
            }
          }
      );

      api.registerValueTransformer(
        "category-available-views",
        ({ value, context }) => {
          if (
            context.customFields?.location_enabled &&
            siteSettings.location_category_map_filter
          ) {
            value.push({ name: i18n("filters.map.label"), value: "map" });
          }
          return value;
        }
      );

      const mapRoutes = ["map", "map-category", "map-category-none"];

      mapRoutes.forEach(function (route) {
        if (container.factoryFor(`route:discovery.${route}`)) {
          api.modifyClass(
            `route:discovery.${route}`,
            (Superclass) =>
              class extends Superclass {
                pluginId = "locations-plugin";

                afterModel() {
                  this.templateName = "discovery/map";

                  return super.afterModel(...arguments);
                }
              }
          );
        }
      });

      const categoryRoutes = ["category", "category-all", "category-none"];

      categoryRoutes.forEach(function (route) {
        if (!container.factoryFor(`route:discovery.${route}`)) {
          return;
        }

        api.modifyClass(
          `route:discovery.${route}`,
          (Superclass) =>
            class extends Superclass {
              pluginId = "locations-plugin";

              afterModel(model) {
                if (
                  model?.category &&
                  this.filter(model.category) === "map" &&
                  siteSettings.location_category_map_filter
                ) {
                  this.templateName = "discovery/map";
                } else {
                  this.templateName = "discovery/list";
                }

                return super.afterModel(...arguments);
              }
            }
        );
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
          siteSettings.location_category_map_filter
        ) {
          items.push(NavItem.fromText("map", args)); // Show category level "/map" instead
        }

        return items;
      },
    });
  },
};
