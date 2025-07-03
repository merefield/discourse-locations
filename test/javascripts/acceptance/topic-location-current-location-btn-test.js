import { click, visit } from "@ember/test-helpers";
import {
  acceptance,
  exists,
  query,
  visible,
} from "discourse/tests/helpers/qunit-helpers";
import { cloneJSON } from "discourse-common/lib/object";
import locationFixtures from "../fixtures/location-fixtures";
import siteFixtures from "../fixtures/site-fixtures";
import topicFixtures from "../fixtures/topic-fixtures";
import { test } from "qunit";
import sinon from "sinon";

acceptance(
  "Topic - Set Location using Current Location Button",
  function (needs) {
    needs.user({ username: "demetria_gutmann", id: 134 });
    needs.settings({
      location_enabled: true,
      location_input_fields_enabled: true,
      location_input_fields: "coordinates",
    });
    needs.site(cloneJSON(siteFixtures["site.json"]));
    needs.pretender((server, helper) => {
      const topicResponse = cloneJSON(topicFixtures["/t/51/1.json"]);
      server.get("/t/51/1.json", () => helper.response(topicResponse));
      const locationResponse = cloneJSON(locationFixtures["location.json"]);
      server.get("/locations/search", () => helper.response(locationResponse));
    });

    test("set coordinates from browser geolocation using Current Location button", async function (assert) {
      // Stub getCurrentPosition
      const fakeCoords = { latitude: 10.123, longitude: 20.456 };
      const stub = sinon
        .stub(navigator.geolocation, "getCurrentPosition")
        .callsFake((success) => {
          success({ coords: fakeCoords });
        });

      await visit("/t/online-learning/51/1");
      await click("a.edit-topic");
      await click("button.add-location-btn");
      assert.ok(visible(".add-location-modal"), "add location modal is shown");
      await click(".location-current-btn");
      assert.equal(
        query(
          ".add-location div.location-form div.coordinates .input-location.lat"
        ).value,
        "10.123",
        "Latitude is set from geolocation"
      );
      assert.equal(
        query(
          ".add-location div.location-form div.coordinates .input-location.lon"
        ).value,
        "20.456",
        "Longitude is set from geolocation"
      );
      stub.restore();
    });
  }
);
