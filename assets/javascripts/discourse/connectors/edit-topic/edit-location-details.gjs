import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action, get, set } from "@ember/object";
import AddLocationControls from "../../components/add-location-controls";

export default class EditLocationDetails extends Component {
  @tracked location = get(this.args.outletArgs.buffered, "location");

  @action
  updateLocation(location) {
    set(this.args.outletArgs.buffered, "location", location);
    this.location = location;
  }

  <template>
    {{log @model}}
    {{#if @outletArgs.model.showLocationControls}}
      <AddLocationControls
        @location={{this.location}}
        @category={{@outletArgs.buffered.category}}
        @updateLocation={{this.updateLocation}}
      />
    {{/if}}
  </template>
}
