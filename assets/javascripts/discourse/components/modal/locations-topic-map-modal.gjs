import Component from "@ember/component";
import DModal from "discourse/components/d-modal";
import { i18n } from "discourse-i18n";
import LocationsMap from "./../locations-map";

export default class LocationsTopicMapModalComponent extends Component {
  get topic() {
    return this.args.model.topic;
  }

  get title() {
    return i18n("map.topic_modal.label", {
      topic_title: this.topic.title,
    });
  }

  <template>
    <DModal
      @title={{this.title}}
      @closeModal={{@closeModal}}
      class="locations-map-modal"
    >
      <LocationsMap @topic={{this.topic}} @mapType="topic" />
    </DModal>
  </template>
}
