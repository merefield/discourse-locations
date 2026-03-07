import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";

module(
  "Discourse Locations | Component | locations-topic-map-modal",
  function (hooks) {
    setupRenderingTest(hooks);

    test("uses args.model.topic consistently", async function (assert) {
      this.model = {
        topic: {
          title: "Modal Topic",
        },
      };
      this.closeModal = () => {};

      await render(hbs`
        <Modal::LocationsTopicMapModal
          @inline={{true}}
          @model={{this.model}}
          @closeModal={{this.closeModal}}
        />
      `);

      assert.dom(".locations-map-modal").exists();
      assert.dom(".d-modal__title-text").hasText("Topic Location: Modal Topic");
      assert.dom("#locations-map").exists();
    });
  }
);
