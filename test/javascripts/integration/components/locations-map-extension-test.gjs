import { fn, hash } from "@ember/helper";
import { on } from "@ember/modifier";
import { click, fillIn, render } from "@ember/test-helpers";
import { module, test } from "qunit";
import sinon from "sinon";
import { withPluginApi } from "discourse/lib/plugin-api";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import LocationsMap from "discourse/plugins/discourse-locations/discourse/components/locations-map";

module("Integration | Component | LocationsMap", function (hooks) {
  setupRenderingTest(hooks);

  test("an outlet control can replace users-map request parameters", async function (assert) {
    const store = this.owner.lookup("service:store");
    const findStub = sinon.stub(store, "find").resolves([]);

    withPluginApi((api) => {
      api.renderInOutlet(
        "locations-users-map-controls",
        <template>
          <button
            type="button"
            class="test-set-users-map-params"
            {{on
              "click"
              (fn @outletArgs.setRequestParams (hash group="team" limit=10))
            }}
          >Set filters</button>
          <button
            type="button"
            class="test-clear-users-map-params"
            {{on "click" (fn @outletArgs.setRequestParams null)}}
          >Clear filters</button>
          <span class="test-users-map-group">
            {{@outletArgs.requestParams.group}}
          </span>
        </template>
      );
    });

    await render(<template><LocationsMap @mapType="userList" /></template>);

    assert.deepEqual(
      findStub.firstCall.args,
      ["directoryItem", { period: "location" }],
      "the base request has no extension parameters"
    );

    await click(".test-set-users-map-params");

    assert
      .dom(".test-users-map-group")
      .hasText("team", "the controls outlet receives the current parameters");
    assert.deepEqual(
      findStub.lastCall.args,
      ["directoryItem", { group: "team", limit: 10, period: "location" }],
      "setting parameters reloads the user list"
    );

    await click(".test-clear-users-map-params");

    assert
      .dom(".test-users-map-group")
      .hasNoText("invalid parameters are exposed as an empty object");
    assert.deepEqual(
      findStub.lastCall.args,
      ["directoryItem", { period: "location" }],
      "invalid parameters restore the base request"
    );
  });

  test("surface outlets can activate and restore an alternative surface", async function (assert) {
    const store = this.owner.lookup("service:store");
    sinon.stub(store, "find").resolves([]);

    withPluginApi((api) => {
      api.renderInOutlet(
        "locations-users-map-controls",
        <template>
          <button
            type="button"
            class="test-set-users-map-surface"
            {{on "click" (fn @outletArgs.setActiveSurface "globe")}}
          >Set surface</button>
          <span class="test-users-map-control-surface">
            {{@outletArgs.activeSurface}}
          </span>
        </template>
      );

      api.renderInOutlet(
        "locations-users-map-surface",
        <template>
          <button
            type="button"
            class="test-reset-users-map-surface"
            {{on "click" (fn @outletArgs.setActiveSurface null)}}
          >Reset surface</button>
          <span class="test-users-map-surface">
            {{@outletArgs.activeSurface}}
          </span>
        </template>
      );
    });

    await render(<template><LocationsMap @mapType="userList" /></template>);

    assert
      .dom("#locations-map")
      .doesNotHaveClass(
        "has-alternative-surface",
        "the base map is the default surface"
      );

    await click(".test-set-users-map-surface");

    assert
      .dom("#locations-map")
      .hasClass(
        "has-alternative-surface",
        "selecting an extension surface hides the base map controls"
      );
    assert
      .dom(".test-users-map-control-surface")
      .hasText("globe", "the controls outlet receives the active surface");
    assert
      .dom(".test-users-map-surface")
      .hasText("globe", "the surface outlet receives the active surface");

    await click(".test-reset-users-map-surface");

    assert
      .dom("#locations-map")
      .doesNotHaveClass(
        "has-alternative-surface",
        "the surface outlet can restore the base map"
      );
  });

  test("the base map remains the default without a surface extension", async function (assert) {
    const store = this.owner.lookup("service:store");
    sinon.stub(store, "find").resolves([]);

    await render(<template><LocationsMap @mapType="userList" /></template>);

    assert
      .dom("#locations-map")
      .doesNotHaveClass(
        "has-alternative-surface",
        "the default state does not activate an alternative surface"
      );
    assert
      .dom("#locations-map > .leaflet-container")
      .exists("the base Leaflet surface is still rendered");
    assert
      .dom("#locations-map > .btn-map")
      .exists("the base map controls are still rendered");
  });

  test("a surface receives filtered locations and can clear search", async function (assert) {
    const store = this.owner.lookup("service:store");
    sinon.stub(store, "find").resolves([
      {
        user: {
          id: 1,
          avatar_template: "/avatar/1/{size}.png",
          geo_location: { lat: 51.5, lon: -0.1 },
          name: "Alpha User",
          username: "alpha",
        },
      },
      {
        user: {
          id: 2,
          avatar_template: "/avatar/2/{size}.png",
          geo_location: { lat: 48.8, lon: 2.3 },
          name: "Bravo User",
          username: "bravo",
        },
      },
    ]);

    withPluginApi((api) => {
      api.renderInOutlet(
        "locations-users-map-surface",
        <template>
          <span class="test-surface-location-count">
            {{@outletArgs.locations.length}}
          </span>
          <span class="test-surface-search-filter">
            {{@outletArgs.searchFilter}}
          </span>
          <button
            type="button"
            class="test-clear-surface-search"
            {{on "click" @outletArgs.clearSearchFilter}}
          >Clear search</button>
        </template>
      );
    });

    await render(<template><LocationsMap @mapType="userList" /></template>);

    assert
      .dom(".test-surface-location-count")
      .hasText("2", "the surface receives all loaded map locations");

    await fillIn(".map-search > input[type='text']", "Alpha");

    assert
      .dom(".test-surface-location-count")
      .hasText("1", "the surface receives the locally filtered locations");
    assert
      .dom(".test-surface-search-filter")
      .hasText("Alpha", "the surface receives the current local search");

    await click(".test-clear-surface-search");

    assert
      .dom(".map-search > input[type='text']")
      .hasValue("", "the surface can clear the base search input");
    assert
      .dom(".test-surface-location-count")
      .hasText("2", "clearing search restores all surface locations");
  });
});
