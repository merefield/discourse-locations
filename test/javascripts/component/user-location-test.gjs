import { render } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import UserLocation from "discourse/plugins/discourse-locations/discourse/components/user-location";

module("Integration | Component | UserLocation", function (hooks) {
  setupRenderingTest(hooks);

  test("disables the map button when another Leaflet map is present", async function (assert) {
    this.site.country_codes = [{ code: "gb", name: "United Kingdom" }];
    this.user = {
      geo_location: {
        address: "London, United Kingdom",
        city: "London",
        countrycode: "gb",
      },
    };

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
});
