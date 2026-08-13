import { fn, hash } from "@ember/helper";
import { on } from "@ember/modifier";
import { click, render } from "@ember/test-helpers";
import { module, test } from "qunit";
import sinon from "sinon";
import { withPluginApi } from "discourse/lib/plugin-api";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import LocationsMap from "discourse/plugins/discourse-locations/discourse/components/locations-map";

module(
  "Discourse Locations | Integration | locations map extension",
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
            <span class="test-users-map-group">
              {{@outletArgs.requestParams.group}}
            </span>
          </template>
        );
      });

      await render(<template><LocationsMap @mapType="userList" /></template>);

      assert.deepEqual(findStub.firstCall.args, [
        "directoryItem",
        { period: "location" },
      ]);

      await click(".test-set-users-map-params");

      assert.dom(".test-users-map-group").hasText("team");
      assert.deepEqual(findStub.lastCall.args, [
        "directoryItem",
        { group: "team", limit: 10, period: "location" },
      ]);
    });
  }
);
