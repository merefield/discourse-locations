import Component from "@glimmer/component";
import { service } from "@ember/service";
import { geoLocationFormat } from "../../lib/location-utilities";
import NationalFlag from "../../components/national-flag";

export default class LocationMapComponent extends Component {
  @service siteSettings;
  @service site;

  get locationText() {
    let model = this.args.post;

    if (model.user_custom_fields && model.user_custom_fields["geo_location"]) {
      let format = this.siteSettings.location_user_post_format.split("|");
      let opts = {};

      if (format.length) {
        opts["geoAttrs"] = format;
      }

      return geoLocationFormat(
        model.user_custom_fields["geo_location"],
        this.site.country_codes,
        opts
      );
    }
    return "";
  }

  get countryCode() {
    let model = this.args.post;

    if (model.user_custom_fields && model.user_custom_fields["geo_location"]) {
      return model.user_custom_fields["geo_location"].countrycode;
    }
    return null;
  }

  get showFlag() {
    return (
      this.siteSettings.location_user_country_flag &&
      this.countryCode
    );
  }

  <template>
    {{yield}}
    <div class="location-summary">
      <div class="user-location">{{this.locationText}}</div>
      <div class="location-flag">
      {{#if this.showFlag}}
        <NationalFlag @countryCode={{this.countryCode}} />
      {{/if}}
      </div>
    </div>
  </template>
}
