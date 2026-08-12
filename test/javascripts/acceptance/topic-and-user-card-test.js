import { click, visit } from "@ember/test-helpers";
import { test } from "qunit";
import { cloneJSON } from "discourse/lib/object";
import { acceptance, query } from "discourse/tests/helpers/qunit-helpers";
import locationFixtures from "../fixtures/location-fixtures";
import siteFixtures from "../fixtures/site-fixtures";
import topicFixtures from "../fixtures/topic-fixtures";
import userFixtures from "../fixtures/user-fixtures";

acceptance(
  "Topic & User Card - Show Correct User Location Format",
  function (needs) {
    let useLongLocation;

    needs.hooks.beforeEach(() => {
      useLongLocation = false;
    });

    needs.user({
      username: "demetria_gutmann",
      id: 134,
    });
    needs.settings({
      location_enabled: true,
      location_user_profile_format: "city|countrycode",
      location_user_post_format: "city|countrycode",
      location_input_fields_enabled: true,
      location_auto_infer_street_from_address_data: true,
      location_user_post: true,
      location_users_map: true,
      hide_user_profiles_from_public: false,
    });
    needs.site(cloneJSON(siteFixtures["site.json"]));
    needs.pretender((server, helper) => {
      server.get("/u/merefield/card.json", () => {
        const cardResponse = cloneJSON(userFixtures["/u/merefield/card.json"]);

        if (useLongLocation) {
          cardResponse.user.geo_location.city = "A".repeat(160);
        }

        return helper.response(cardResponse);
      });
      const topicResponse = cloneJSON(topicFixtures["/t/51/1.json"]);
      server.get("/t/51/1.json", () => helper.response(topicResponse));
      const locationResponse = cloneJSON(locationFixtures["location.json"]);
      server.get("/locations/search", () => helper.response(locationResponse));
    });

    test("topic title location, post user & user card location - shows correct format", async function (assert) {
      await visit("/t/online-learning/51/1");
      assert.strictEqual(
        query("span.location-text").innerText,
        "Pompidou, Paris, France"
      );

      assert.strictEqual(
        query(".small-action-desc.timegap").innerText,
        "2 years later"
      );

      assert.strictEqual(
        query("#post_3 .user-location").innerText,
        "Paris, France"
      );

      await click('a[data-user-card="merefield"]');

      assert.strictEqual(
        query(".user-card .location-label").innerText,
        "London, United Kingdom"
      );
    });

    test("long user locations stay within the user card", async function (assert) {
      useLongLocation = true;

      await visit("/t/online-learning/51/1");
      await click('a[data-user-card="merefield"]');

      const card = query(".user-card");
      const location = query(".user-card .location-label");
      const locationButton = location.closest("button");
      const cardRect = card.getBoundingClientRect();
      const buttonRect = locationButton.getBoundingClientRect();

      assert.dom(location).includesText("A".repeat(160));
      assert.strictEqual(
        getComputedStyle(location).overflowWrap,
        "anywhere",
        "unbroken location text can wrap"
      );
      assert.true(
        buttonRect.left >= cardRect.left,
        "the location button starts inside the card"
      );
      assert.true(
        buttonRect.right <= cardRect.right,
        "the location button ends inside the card"
      );
      assert.true(
        location.scrollWidth <= location.clientWidth,
        "the location text does not overflow horizontally"
      );
    });
  }
);
