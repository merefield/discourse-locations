import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action, get } from "@ember/object";
import AddLocationControls from "../../components/add-location-controls";

export default class EditLocationDetails extends Component {
  @tracked location = get(this.args.outletArgs.buffered, "location");

  @action
  updateLocation(location) {
    this.args.outletArgs.buffered.buffer = {
      location,
    };
    this.args.outletArgs.buffered.hasBufferedChanges = true;
    this.location = location;
  }

  <template>
    {{#if @outletArgs.model.showLocationControls}}
      <AddLocationControls
        @location={{this.location}}
        @category={{@outletArgs.buffered.category}}
        @updateLocation={{this.updateLocation}}
      />
    {{/if}}
  </template>
}
