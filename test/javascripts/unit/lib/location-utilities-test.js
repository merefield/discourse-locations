import { module, test } from "qunit";
import { parseGeoLocation } from "discourse/plugins/discourse-locations/discourse/lib/location-utilities";

module("Unit | Lib | location-utilities", function () {
  test("parseGeoLocation returns an object unchanged", function (assert) {
    const location = { lat: 51.5074, lon: -0.1278 };

    assert.deepEqual(
      parseGeoLocation(location),
      location,
      "an object is returned unchanged"
    );
  });

  test("parseGeoLocation parses a serialized location", function (assert) {
    const location = { lat: 51.5074, lon: -0.1278 };

    assert.deepEqual(
      parseGeoLocation(JSON.stringify(location)),
      location,
      "a JSON string is parsed"
    );
  });

  test("parseGeoLocation rejects invalid JSON", function (assert) {
    assert.strictEqual(
      parseGeoLocation("not-json"),
      null,
      "invalid JSON returns no location"
    );
  });

  test("parseGeoLocation rejects empty locations", function (assert) {
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
