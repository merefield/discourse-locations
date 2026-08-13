import { module, test } from "qunit";
import { parseGeoLocation } from "discourse/plugins/discourse-locations/discourse/lib/location-utilities";

module("Unit | Lib | location-utilities", function () {
  test("parseGeoLocation normalizes supported location values", function (assert) {
    const location = { lat: 51.5074, lon: -0.1278 };

    assert.deepEqual(
      parseGeoLocation(location),
      location,
      "an object is returned unchanged"
    );
    assert.deepEqual(
      parseGeoLocation(JSON.stringify(location)),
      location,
      "a JSON string is parsed"
    );
    assert.strictEqual(
      parseGeoLocation("not-json"),
      null,
      "invalid JSON returns no location"
    );
    assert.strictEqual(
      parseGeoLocation(" { } "),
      null,
      "an empty object string returns no location"
    );
    assert.strictEqual(
      parseGeoLocation({}),
      null,
      "an empty object returns no location"
    );
  });
});
