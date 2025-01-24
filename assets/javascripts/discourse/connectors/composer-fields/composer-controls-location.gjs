import Component from "@glimmer/component";
import { action, set } from "@ember/object";
import AddLocationControls from "../../components/add-location-controls";

export default class ComposerControlsLocation extends Component {


  @action
  updateLocation(location) {
    set(this.args.outletArgs.model, "location", location);
  }

  <template>
    {{log this.model}}
     {{log this.args.model.showLocationControls}}
    {{#if @outletArgs.model.showLocationControls}}
      <AddLocationControls
        @location={{@outletArgs.model.location}}
        @category={{@outletArgs.model.category}}
        @noText={{this.site.mobileView}}
        @updateLocation={{this.updateLocation}}
      />
    {{/if}}
  </template>
}
