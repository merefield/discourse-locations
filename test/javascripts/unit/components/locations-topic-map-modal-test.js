import { setupTest } from "ember-qunit";
import { module, test } from "qunit";
import LocationsTopicMapModal from "discourse/plugins/discourse-locations/discourse/components/modal/locations-topic-map-modal";

module(
  "Discourse Locations | Unit | Component | locations-topic-map-modal",
  function (hooks) {
    setupTest(hooks);

    test("uses args.model.topic consistently", function (assert) {
      const topic = { title: "Modal Topic" };
      const component = Object.create(LocationsTopicMapModal.prototype);
      component.args = { model: { topic } };

      assert.strictEqual(component.topic, topic);
      assert.strictEqual(component.title, "Topic Location: Modal Topic");
    });
  }
);
