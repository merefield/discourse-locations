import { click, render } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import UserLocation from "discourse/plugins/discourse-locations/discourse/components/user-location";

module("Integration | Component | UserLocation", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.site.country_codes = [{ code: "gb", name: "United Kingdom" }];
    this.user = {
      geo_location: {
        address: "London, United Kingdom",
        city: "London",
        countrycode: "gb",
        lat: 51.5072,
        lon: -0.1276,
      },
    };
  });

  test("disables the map button when another Leaflet map is present", async function (assert) {
    await render(
      <template>
        <div class="leaflet-container"></div>
        <UserLocation @user={{this.user}} />
      </template>
    );

    assert
      .dom(".btn-show-map")
      .isDisabled("the user map cannot be opened alongside another map");
  });

  test("allows the user to close the profile map", async function (assert) {
    await render(<template><UserLocation @user={{this.user}} /></template>);

    await click(".btn-show-map");

    assert.dom("#locations-map").exists("the profile map opens");
    assert
      .dom(".btn-show-map")
      .isNotDisabled("the map button remains available while its map is open");

    await click(".btn-show-map");

    assert.dom("#locations-map").doesNotExist("the profile map closes");
  });
});
