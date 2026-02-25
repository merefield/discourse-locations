import Component from "@glimmer/component";
import DModal from "discourse/components/d-modal";
import { i18n } from "discourse-i18n";
import LocationsMap from "./../locations-map";

export default class LocationsTopicMapModalComponent extends Component {
  get title() {
    return i18n("map.topic_modal.label", {
      topic_title: this.model.topic.title,
    });
  }

  <template>
    <DModal
      @title={{this.title}}
      @closeModal={{@closeModal}}
      class="locations-map-modal"
    >
      <LocationsMap @topic={{this.model.topic}} @mapType="topic" />
    </DModal>
  </template>
}
