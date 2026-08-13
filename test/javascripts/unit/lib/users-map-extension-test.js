import { module, test } from "qunit";
import { buildUsersMapRequestParams } from "discourse/plugins/discourse-locations/discourse/lib/users-map-extension";

module("Discourse Locations | Unit | Lib | users-map-extension", function () {
  test("builds a location-directory request without allowing the period to be replaced", function (assert) {
    const extensionParams = { group: "team", period: "all", user_limit: 10 };

    assert.deepEqual(
      buildUsersMapRequestParams(extensionParams),
      {
        group: "team",
        period: "location",
        user_limit: 10,
      },
      "extension parameters are retained but cannot replace the period"
    );
    assert.strictEqual(extensionParams.period, "all", "does not mutate input");
  });

  test("ignores unsupported parameter values", function (assert) {
    for (const extensionParams of [null, undefined, "group", 10, ["team"]]) {
      assert.deepEqual(
        buildUsersMapRequestParams(extensionParams),
        { period: "location" },
        `${String(extensionParams)} is treated as an empty parameter object`
      );
    }
  });
});
