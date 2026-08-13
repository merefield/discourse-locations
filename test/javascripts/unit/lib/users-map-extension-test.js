import { module, test } from "qunit";
import { buildUsersMapRequestParams } from "discourse/plugins/discourse-locations/discourse/lib/users-map-extension";

module("Discourse Locations | Unit | users map extension", function () {
  test("builds a location-directory request without allowing the period to be replaced", function (assert) {
    const extensionParams = { group: "team", period: "all", user_limit: 10 };

    assert.deepEqual(buildUsersMapRequestParams(extensionParams), {
      group: "team",
      period: "location",
      user_limit: 10,
    });
    assert.strictEqual(extensionParams.period, "all", "does not mutate input");
  });
});
