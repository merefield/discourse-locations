import { click, visit, waitFor } from "@ember/test-helpers";
import { test } from "qunit";
import { cloneJSON } from "discourse/lib/object";
import { acceptance } from "discourse/tests/helpers/qunit-helpers";
import siteFixtures from "../fixtures/site-fixtures";

function buildSiteFixture() {
  const site = cloneJSON(siteFixtures["site.json"]);
  site.can_create_topic = true;
  const defaultCategory = site.categories.find(
    (category) => category.id === 11
  );
  defaultCategory.permission = 1;
  return site;
}

acceptance(
  "Composer (locations) | don't show default location as user location when behaviour set",
  function (needs) {
    needs.user({
      username: "demetria_gutmann",
      id: 134,
      custom_fields: {
        geo_location: {
          lat: "51.5073219",
          lon: "-0.1276474",
          address: "London, Greater London, England, United Kingdom",
          countrycode: "gb",
          city: "London",
          state: "England",
          country: "United Kingdom",
          postalcode: "",
          boundingbox: ["51.2867601", "51.6918741", "-0.5103751", "0.3340155"],
          type: "city",
        },
      },
    });
    needs.site(buildSiteFixture());
    needs.settings({
      location_enabled: true,
      location_users_map: true,
      hide_user_profiles_from_public: false,
      location_topic_default: "none",
      default_composer_category: 11,
    });

    test("composer doesn't contain default location", async function (assert) {
      await visit("/");
      assert.dom("#create-topic").exists();
      await click("#create-topic");
      await waitFor(".composer-controls-location span.d-button-label");

      assert
        .dom(".composer-controls-location span.d-button-label")
        .hasText("Add Location");
    });
  }
);

acceptance(
  "Composer (locations) | - show default location as user location when behaviour set",
  function (needs) {
    needs.user({
      username: "demetria_gutmann",
      id: 134,
      custom_fields: {
        geo_location: {
          lat: "51.5073219",
          lon: "-0.1276474",
          address: "London, Greater London, England, United Kingdom",
          countrycode: "gb",
          city: "London",
          state: "England",
          country: "United Kingdom",
          postalcode: "",
          boundingbox: ["51.2867601", "51.6918741", "-0.5103751", "0.3340155"],
          type: "city",
        },
      },
    });
    needs.site(buildSiteFixture());
    needs.settings({
      location_enabled: true,
      location_users_map: true,
      hide_user_profiles_from_public: false,
      location_topic_default: "user",
      default_composer_category: 11,
    });

    test("composer includes default location", async function (assert) {
      await visit("/");
      assert.dom("#create-topic").exists();
      await click("#create-topic");
      await waitFor(".composer-controls-location span.d-button-label");

      assert
        .dom(".composer-controls-location span.d-button-label")
        .hasText("London, Greater London, England, United Kingdom");

      assert.dom(".composer-controls-location .remove").exists();
      await click(".composer-controls-location .remove");

      assert
        .dom(".composer-controls-location span.d-button-label")
        .hasText("Add Location");
    });
  }
);
