import Component from "@glimmer/component";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import didUpdate from "@ember/render-modifiers/modifiers/did-update";
import { service } from "@ember/service";
import AddLocationControls from "../../components/add-location-controls";

export default class ComposerControlsLocation extends Component {
  @service site;

  get model() {
    return this.args.outletArgs.model;
  }

  @action
  updateLocation(location) {
    this.model.location = location;
  }

  // Runs on open and whenever the draft or category changes, replacing the
  // composer model's former `init` + `@observes("draftKey", "categoryId")`.
  @action
  setupDefaultLocation() {
    this.model.maybeSetupDefaultLocation();
  }

  <template>
    <div
      {{didInsert this.setupDefaultLocation}}
      {{didUpdate
        this.setupDefaultLocation
        this.model.draftKey
        this.model.categoryId
        this.model.showLocationControls
      }}
    >
      {{#if this.model.showLocationControls}}
        <AddLocationControls
          @location={{this.model.location}}
          @category={{this.model.category}}
          @noText={{this.site.mobileView}}
          @updateLocation={{this.updateLocation}}
        />
      {{/if}}
    </div>
  </template>
}
