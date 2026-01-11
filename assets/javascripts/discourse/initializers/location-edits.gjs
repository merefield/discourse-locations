import { computed } from "@ember/object";
import { next, scheduleOnce } from "@ember/runloop";
import { observes } from "@ember-decorators/object";
import SortableColumn from "discourse/components/topic-list/header/sortable-column";
import { withPluginApi } from "discourse/lib/plugin-api";
import Composer from "discourse/models/composer";
import NavItem from "discourse/models/nav-item";
import discourseComputed from "discourse-common/utils/decorators";
import I18n from "I18n";

const NEW_TOPIC_KEY = "new_topic";
const LOCATIONS_LIST_ROUTES = ["discovery.nearby"];

function formatDistance(distance) {
  if (!Number.isFinite(distance)) {
    return "";
  }

  return I18n.toNumber(distance, {
    precision: 2,
    strip_insignificant_zeros: false,
  });
}

const locationsDistanceHeader = <template>
  <SortableColumn
    @sortable={{@sortable}}
    @number="false"
    @order="distance"
    @activeOrder={{@activeOrder}}
    @changeSort={{@changeSort}}
    @ascending={{@ascending}}
    @name="distance"
  />
</template>;

const locationsDistanceCell = <template>
  <td class="distance">
    {{#if @topic.distance}}
      {{formatDistance @topic.distance}}
    {{/if}}
  </td>
</template>;

export default {
  name: "location-edits",
  initialize(container) {
    withPluginApi("0.8.23", (api) => {
      const router = container.lookup("service:router");
      const siteSettings = container.lookup("service:site-settings");
      const currentUser = container.lookup("service:current-user");
      const userHasLocation = currentUser?.custom_fields?.geo_location &&
        ((typeof currentUser.custom_fields.geo_location === "string" &&
          currentUser.custom_fields.geo_location.replaceAll(" ", "") !== "{}") ||
          (typeof currentUser.custom_fields.geo_location === "object" &&
            Object.keys(currentUser.custom_fields.geo_location).length !== 0));

      if (!siteSettings.location_enabled) {
        return;
      }

      if (siteSettings.location_nearby_list_max_distance_km > 0 && userHasLocation) {
        api.addNavigationBarItem({
          name: "nearby",
          href: "/nearby",
        });

        api.registerValueTransformer("topic-list-item-class", ({ value }) => {
          if (LOCATIONS_LIST_ROUTES.includes(router.currentRouteName)) {
            value.push("locations-list");
          }
          return value;
        });

        api.registerValueTransformer(
          "topic-list-columns",
          ({ value: columns }) => {
            if (LOCATIONS_LIST_ROUTES.includes(router.currentRouteName)) {
              columns.add("distance", {
                header: locationsDistanceHeader,
                item: locationsDistanceCell,
                after: "activity",
              });
            }
            return columns;
          }
        );
      }

      api.modifyClass(
        "controller:users",
        (Superclass) =>
          class extends Superclass {
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
            @computed("categoryId", "topicFirstPost", "forceLocationControls")
            get showLocationControls() {
              const categoryId = this.get("categoryId");
              const topicFirstPost = this.get("topicFirstPost");
              const force = this.get("forceLocationControls");

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
                if (category && category.custom_fields?.location_enabled) {
                  return true;
                }
              }
              return false;
            }

            clearState() {
              super.clearState(...arguments);
              this.set("location", null);
            }

            init() {
              super.init(...arguments);
              this._maybeSetupDefaultLocation();
            }

            @observes("composeState", "draftKey")
            _maybeSetupDefaultLocation() {
              const draftKey = this.draftKey;
              if (!draftKey) {
                next(this, this._maybeSetupDefaultLocation);
                return;
              }

              if (draftKey.startsWith(NEW_TOPIC_KEY)) {
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
                      Object.keys(this.user.custom_fields.geo_location)
                        .length !== 0))
                ) {
                  this.set("location", {
                    geo_location: this.user.custom_fields.geo_location,
                  });
                }
              }
            }
          }
      );

      api.modifyClass(
        "component:composer-body",
        (Superclass) =>
          class extends Superclass {
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
            // @computed("subtype", "category.custom_fields.location_enabled")
            get showLocationControls() {
              const subtype = this.get("subtype");
              const categoryEnabled = this.get(
                "category.custom_fields.location_enabled"
              );
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
            @observes("editingTopic")
            setEditingTopicOnModel() {
              this.set("model.editingTopic", this.get("editingTopic"));
            }
          }
      );

      api.modifyClass(
        "component:edit-category-settings",
        (Superclass) =>
          class extends Superclass {
            @discourseComputed("category.id", "category.custom_fields")
            availableViews() {
              const category = this.get("category");
              let views = super.availableViews(...arguments);

              if (
                category.get("custom_fields.location_enabled") &&
                this.siteSettings.location_category_map_filter
              ) {
                views.push({ name: I18n.t("filters.map.label"), value: "map" });
              }

              return views;
            }
          }
      );

      const mapRoutes = [`Map`, `MapCategory`, `MapCategoryNone`];

      mapRoutes.forEach(function (route) {
        api.modifyClass(
          `route:discovery.${route}`,
          (Superclass) =>
            class extends Superclass {
              afterModel() {
                this.templateName = "discovery/map";

                return super.afterModel(...arguments);
              }
            }
        );
      });

      const categoryRoutes = ["category", "categoryNone"];

      categoryRoutes.forEach(function (route) {
        api.modifyClass(
          `route:discovery.${route}`,
          (Superclass) =>
            class extends Superclass {
              afterModel(model, transition) {
                if (
                  this.filter(model.category) === "map" &&
                  this.siteSettings.location_category_map_filter
                ) {
                  transition.abort();
                  return this.replaceWith(
                    `/c/${this.Category.slugFor(
                      model.category
                    )}/l/${this.filter(model.category)}`
                  );
                } else {
                  return super.afterModel(...arguments);
                }
              }
            }
        );
      });
      api.modifyClass("component:d-menu", (Superclass) => {
        return class extends Superclass {
          get options() {
            // take the real options object from the instance
            const base = this.menuInstance?.options ?? {};

            // IMPORTANT: override inline from args at read-time
            // so DFloatBody/DFloatPortal see it during the same render
            if (
              this.args?.inline !== undefined &&
              base.inline !== this.args.inline
            ) {
              return { ...base, inline: this.args.inline };
            }

            return base;
          }
        };
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
