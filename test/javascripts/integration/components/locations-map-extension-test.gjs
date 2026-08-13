import { fn, hash } from "@ember/helper";
import { on } from "@ember/modifier";
import { click, render } from "@ember/test-helpers";
import { module, test } from "qunit";
import sinon from "sinon";
import { withPluginApi } from "discourse/lib/plugin-api";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import LocationsMap from "discourse/plugins/discourse-locations/discourse/components/locations-map";

module(
  "Discourse Locations | Integration | Component | LocationsMap",
  function (hooks) {
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
        .hasText("team", "the outlet receives the current parameters");
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
  }
);
