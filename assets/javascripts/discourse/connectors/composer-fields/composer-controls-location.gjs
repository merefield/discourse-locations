import Component from "@glimmer/component";
import { action } from "@ember/object";
import AddLocationControls from  "../../components/location-label-container";

export default class ComposerControlsLocation extends Component {

  @action
  updateLocation(location) {
    this.model.location = location;
  }

  <template>
    {{#if this.model.showLocationControls}}
      <AddLocationControls
        @location={{this.model.location}}
        @category={{this.model.category}}
        @noText={{this.site.mobileView}}
        @editing={{true}}
        @updateLocation={{this.updateLocation}}
      />
    {{/if}}
  </template>
}