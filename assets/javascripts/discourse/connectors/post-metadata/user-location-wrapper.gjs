import Component from "@glimmer/component";
import UserLocation from "../../components/user-location";
import { geoLocationFormat } from "../../lib/location-utilities";
import { service } from "@ember/service";


export default class LocationMapComponent extends Component {
  @service siteSettings;
  @service site;

  get locationText() {
      let model = this.args.post.user;

      if (model.custom_fields && model.custom_fields["geo_location"]) {
        let format = this.siteSettings.location_user_post_format.split("|");
        debugger;
        let opts = {};
        if (format.length) {
          opts["geoAttrs"] = format;
        }

        console.log(opts);
        console.log(geoLocationFormat(
          model.custom_fields["geo_location"],
          this.site.country_codes,
          opts
        ));
        return geoLocationFormat(
          model.custom_fields["geo_location"],
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