import Component from "@glimmer/component";
import { service } from "@ember/service";
import { geoLocationFormat } from "../../lib/location-utilities";

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

  <template>
    {{yield}}
    <div class="user-location">{{this.locationText}}</div>
  </template>
}
