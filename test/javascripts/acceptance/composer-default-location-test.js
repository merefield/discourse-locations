import { click, settled, visit, waitFor } from "@ember/test-helpers";
import { test } from "qunit";
import { cloneJSON } from "discourse/lib/object";
import { acceptance } from "discourse/tests/helpers/qunit-helpers";
import siteFixtures from "../fixtures/site-fixtures";
import topicFixtures from "../fixtures/topic-fixtures";

const USER_GEO_LOCATION = {
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
};

function buildSiteFixture() {
  const site = cloneJSON(siteFixtures["site.json"]);
  site.can_create_topic = true;
  const defaultCategory = site.categories.find(
    (category) => category.id === 11
  );
  defaultCategory.permission = 1;
  return site;
}

async function openComposer() {
  await visit("/");
  await click("#create-topic");
  await waitFor("#reply-control.open");
}

function userWithGeoLocation() {
  return {
    username: "demetria_gutmann",
    id: 134,
    custom_fields: {
      geo_location: USER_GEO_LOCATION,
    },
  };
}

acceptance(
  "Composer (locations) | don't show default location as user location when behaviour set",
  function (needs) {
    needs.user(userWithGeoLocation());
    needs.site(buildSiteFixture());
    needs.settings({
      location_enabled: true,
      location_users_map: true,
      hide_user_profiles_from_public: false,
      location_topic_default: "none",
      default_composer_category: 11,
    });

    test("composer doesn't contain default location", async function (assert) {
      await openComposer();
      const composer = this.container.lookup("service:composer");

      assert.strictEqual(composer.model.location, null);
    });
  }
);

acceptance(
  "Composer (locations) | - show default location as user location when behaviour set",
  function (needs) {
    needs.user(userWithGeoLocation());
    needs.site(buildSiteFixture());
    needs.settings({
      location_enabled: true,
      location_users_map: true,
      hide_user_profiles_from_public: false,
      location_topic_default: "user",
      default_composer_category: 11,
    });

    test("composer includes default location", async function (assert) {
      await openComposer();
      const composer = this.container.lookup("service:composer");

      assert.strictEqual(
        composer.model.location.geo_location.address,
        USER_GEO_LOCATION.address
      );
    });

    test("doesn't override an existing composer location", async function (assert) {
      await openComposer();
      const composer = this.container.lookup("service:composer");

      composer.model.set("location", {
        geo_location: {
          ...USER_GEO_LOCATION,
          address: "Custom Draft Address",
        },
      });
      composer.model._maybeSetupDefaultLocation();
      await settled();

      assert.strictEqual(
        composer.model.location.geo_location.address,
        "Custom Draft Address"
      );
    });
  }
);

acceptance(
  "Composer (locations) | - don't apply user default without user location",
  function (needs) {
    needs.user({
      username: "demetria_gutmann",
      id: 134,
      custom_fields: {},
    });
    needs.site(buildSiteFixture());
    needs.settings({
      location_enabled: true,
      location_users_map: true,
      hide_user_profiles_from_public: false,
      location_topic_default: "user",
      default_composer_category: 11,
    });

    test("composer doesn't include default location if user has none", async function (assert) {
      await openComposer();
      const composer = this.container.lookup("service:composer");

      assert.strictEqual(composer.model.location, null);
    });
  }
);

acceptance(
  "Composer (locations) | - don't apply user default when replying",
  function (needs) {
    needs.user(userWithGeoLocation());
    needs.site(buildSiteFixture());
    needs.settings({
      location_enabled: true,
      location_users_map: true,
      hide_user_profiles_from_public: false,
      location_topic_default: "user",
      default_composer_category: 11,
    });
    needs.pretender((server, helper) => {
      const topicResponse = cloneJSON(topicFixtures["/t/51/1.json"]);
      server.get("/t/51/1.json", () => helper.response(topicResponse));
    });

    test("reply composer doesn't receive topic default location", async function (assert) {
      await visit("/t/online-learning/51/1");
      await click("#topic-footer-buttons .btn.create");
      await waitFor("#reply-control.open");
      const composer = this.container.lookup("service:composer");
      const hasDefaultLocation =
        composer.model.location?.geo_location !== undefined &&
        composer.model.location?.geo_location !== null;

      assert.false(composer.model.creatingTopic);
      assert.false(hasDefaultLocation);
    });
  }
);
