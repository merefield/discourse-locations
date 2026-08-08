import Component from "@glimmer/component";
import { action, set } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import didUpdate from "@ember/render-modifiers/modifiers/did-update";
import { service } from "@ember/service";
import AddLocationControls from "../../components/add-location-controls";

export default class ComposerControlsLocation extends Component {
  @service site;

  @action
  updateLocation(location) {
    set(this.args.outletArgs.model, "location", location);
  }

  @action
  syncDefaultLocation() {
    this.args.outletArgs.model.maybeSetupDefaultLocation?.();
  }

  <template>
    <span
      {{didInsert this.syncDefaultLocation}}
      {{didUpdate
        this.syncDefaultLocation
        @outletArgs.model.categoryId
        @outletArgs.model.draftKey
        @outletArgs.model.showLocationControls
      }}
    >
      {{#if @outletArgs.model.showLocationControls}}
        <AddLocationControls
          @location={{@outletArgs.model.location}}
          @category={{@outletArgs.model.category}}
          @noText={{this.site.mobileView}}
          @updateLocation={{this.updateLocation}}
        />
      {{/if}}
    </span>
  </template>
}
