import Component from "@glimmer/component";
import { service } from "@ember/service";
import NationalFlag from "../../components/national-flag";
import { geoLocationFormat } from "../../lib/location-utilities";

export default class LocationMapComponent extends Component {
  @service siteSettings;
  @service site;

  get locationText() {
    const geoLocation = this.args.post.user_geo_location;

    if (geoLocation) {
      let format = this.siteSettings.location_user_post_format.split("|");
      let opts = {};

      if (format.length) {
        opts["geoAttrs"] = format;
      }

      return geoLocationFormat(geoLocation, this.site.country_codes, opts);
    }
    return "";
  }

  get countryCode() {
    return this.args.post.user_geo_location?.countrycode;
  }

  get showFlag() {
    return this.siteSettings.location_user_country_flag && this.countryCode;
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
