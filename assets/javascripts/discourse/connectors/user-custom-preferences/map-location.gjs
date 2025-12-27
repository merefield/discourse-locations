import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { array } from "@ember/helper";
import { action, set } from "@ember/object";
import { service } from "@ember/service";
import icon from "discourse-common/helpers/d-icon";
import i18n from "discourse-common/helpers/i18n";
import LocationSelector from "../../components/location-selector";

export default class UserCustomPrefsMapLocation extends Component {
  @service siteSettings;
  @tracked error = null;

  get parsedGeoLocation() {
    const raw = this.args.model?.custom_fields?.geo_location;

    if (!raw || raw === "{}") {
      return null;
    }

    // already an object (older data / older clients)
    if (typeof raw === "object") {
      return Object.keys(raw).length ? raw : null;
    }

    // JSON string
    if (typeof raw === "string") {
      try {
        const parsed = JSON.parse(raw);
        return parsed && typeof parsed === "object" && Object.keys(parsed).length
          ? parsed
          : null;
      } catch {
        return null;
      }
    }

    return null;
  }

  @action
  searchError(error) {
    this.error = error;
  }

  @action
  updateLocation(location) {
    this.error = null;

    // Normalize clears
    if (
      location == null ||
      location === "" ||
      (typeof location === "object" && Object.keys(location).length === 0)
    ) {
      set(this.args.model, "custom_fields.geo_location", "");
      return;
    }

    // Store as JSON string (server-friendly)
    const value = typeof location === "string" ? location : JSON.stringify(location);
    set(this.args.model, "custom_fields.geo_location", value);
  }

  <template>
    {{#if this.siteSettings.location_users_map}}
      <div class="user-location-selector">
        <div class="control-group">
          <label class="control-label">{{i18n "user.map_location.title"}}</label>
          <div class="controls location-selector-container">
            <LocationSelector
              @location={{this.parsedGeoLocation}}
              @onChangeCallback={{this.updateLocation}}
              class="input-xxlarge location-selector"
              @searchError={{this.searchError}}
              @context={{this.context}}
              @geoAttrs={{array}}
              @showType={{false}}
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
