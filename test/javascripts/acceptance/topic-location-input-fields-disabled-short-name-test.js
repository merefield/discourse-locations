import { click, fillIn, visit } from "@ember/test-helpers";
import { test } from "qunit";
import { cloneJSON } from "discourse/lib/object";
import { acceptance, visible } from "discourse/tests/helpers/qunit-helpers";
import locationFixtures from "../fixtures/location-fixtures";
import siteFixtures from "../fixtures/site-fixtures";
import topicFixtures from "../fixtures/topic-fixtures";

acceptance(
  "Topic - Show Correct Location with Input Fields Disabled and Short Names setting",
  function (needs) {
    needs.user({
      username: "demetria_gutmann",
      id: 134,
    });
    needs.settings({
      location_enabled: true,
      location_input_fields_enabled: false,
      location_auto_infer_street_from_address_data: false,
      location_short_names: true,
    });
    needs.site(cloneJSON(siteFixtures["site.json"]));
    needs.pretender((server, helper) => {
      const topicResponse = cloneJSON(topicFixtures["/t/51/1.json"]);
      server.get("/t/51/1.json", () => helper.response(topicResponse));
      const locationResponse = cloneJSON(locationFixtures["location.json"]);
      server.get("/locations/search", () => helper.response(locationResponse));
    });

    test("enter Topic location via dialogue without address fields", async function (assert) {
      await visit("/t/online-learning/51/1");
      await click("a.fancy-title");
      await click("button.add-location-btn");
      assert.ok(visible(".add-location-modal"), "add location modal is shown");
      await click(".location-selector .d-multi-select-trigger");
      await fillIn(".d-multi-select__search-input", "liver building");
      await click(".location-form-result:first-child label");

      assert
        .dom(".location-selector .d-multi-select-trigger__selection-label")
        .hasText(
          "Royal Liver Building, Water Street, Ropewalks, Liverpool, Liverpool City Region, England, L3 1EG, United Kingdom"
        );

      await fillIn(".location-name", "Home Sweet Home");
      await click("#save-location");

      assert
        .dom("button.add-location-btn span.d-button-label")
        .hasText("Home Sweet Home, L3 1EG, Liverpool, United Kingdom");

      await click("button.submit-edit");
      assert
        .dom(".location-label-container .location-text")
        .hasText("Home Sweet Home");
    });
  }
);
