import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import icon from "discourse-common/helpers/d-icon";
import i18n from "discourse-common/helpers/i18n";
import LocationSelector from "../../components/location-selector";

export default class UserCustomPrefsMapLocation extends Component {
  @service siteSettings;
  @tracked error = null;

  @action
  searchError(error) {
    this.error = error;
  }

  <template>
    {{#if this.siteSettings.location_users_map}}
      <div class="user-location-selector">
        <div class="control-group">
          <label class="control-label">{{i18n
              "user.map_location.title"
            }}</label>
          <div class="controls location-selector-container">
            <LocationSelector
              @location={{@outletArgs.model.custom_fields.geo_location}}
              class="input-xxlarge location-selector"
              @searchError={{this.searchError}}
              @context={{this.context}}
            />
          </div>
          <div class="user-location-warning">
            {{#if this.error}}
              {{this.error}}
            {{else}}
              {{icon "circle-exclamation"}}
              {{i18n "user.map_location.warning"}}
            {{/if}}
          </div>
        </div>
      </div>
    {{/if}}
  </template>
}
