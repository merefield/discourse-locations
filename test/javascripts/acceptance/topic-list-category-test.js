import { visit } from "@ember/test-helpers";
import { test } from "qunit";
import {
  acceptance,
  exists,
  query,
} from "discourse/tests/helpers/qunit-helpers";
import { cloneJSON } from "discourse-common/lib/object";
import siteFixtures from "../fixtures/site-fixtures";
import topicListFixtures from "../fixtures/topic-list-with-location-category";

acceptance("Topic List- Show Correct Topic Location Format for Category", function (needs) {
  needs.user();
  needs.settings({
    location_enabled: true,
  });
  needs.site(cloneJSON(siteFixtures["site.json"]));
  needs.pretender((server, helper) => {
    const topicListResponse = cloneJSON(topicListFixtures["/latest.json"]);
    server.get("/latest.json", () => helper.response(topicListResponse));
  });

  test("topic on topic list location - shows correct format", async function (assert) {
    await visit("/latest");
    debugger;
    assert.ok(
      exists('tr[data-topic-id="142"] span.location-after-title .location-text'),
      "L1 7BL, Liverpool, United Kingdom"
    );
  });
});
