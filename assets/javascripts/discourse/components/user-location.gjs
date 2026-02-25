import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import willDestroy from "@ember/render-modifiers/modifiers/will-destroy";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import icon from "discourse/helpers/d-icon";
import { geoLocationFormat } from "../lib/location-utilities";
import LocationsMap from "./locations-map";
import NationalFlag from "./national-flag";

export default class LocationMapComponent extends Component {
  @service siteSettings;
  @service site;

  @tracked showMap = false;

  outsideClick = (e) => {
    if (
      !this.isDestroying &&
      !(
        e.target.closest(".map-expand") ||
        e.target.closest(".map-attribution") ||
        e.target.closest(".user-location-widget") ||
        e.target.closest("#locations-map")
      )
    ) {
      this.showMap = false;
    }
  };

  get mapButtonLabel() {
    return `location.geo.${this.showMap ? "hide" : "show"}_map`;
  }

  get showMapButtonLabel() {
    return this.args.formFactor !== "card" && !this.site.mobileView;
  }

  get parsedGeoLocation() {
    const raw = this.args.user?.geo_location;

    if (!raw || raw === "{}") {
      return null;
    }

    if (typeof raw === "object") {
      return Object.keys(raw).length ? raw : null;
    }

    return null;
  }

  get userLocation() {
    const geo = this.parsedGeoLocation;
    let locationText = "";

    if (geo) {
      const format = this.siteSettings.location_user_profile_format.split("|");
      const opts = {};

      if (format.length && format[0]) {
        opts.geoAttrs = format;
        locationText = geoLocationFormat(geo, this.site.country_codes, opts);
      } else {
        locationText = geo.address;
      }
    }

    return locationText;
  }

  get canShowMap() {
    return !document.querySelector(".leaflet-container");
  }

  get showFlag() {
    return (
      this.siteSettings.location_user_country_flag &&
      this.parsedGeoLocation &&
      this.parsedGeoLocation.countrycode
    );
  }

  @action
  bindClick() {
    document.addEventListener("click", this.outsideClick);
  }

  @action
  unbindClick() {
    document.removeEventListener("click", this.outsideClick);
  }

  @action
  toggleMap() {
    this.showMap = !this.showMap;
  }

  <template>
    <div
      {{didInsert this.bindClick}}
      {{willDestroy this.unbindClick}}
      class="user-location-widget"
    >
      {{#if this.showMap}}
        <div class="map-container small">
          <LocationsMap @mapType="user" @user={{@user}} />
        </div>
      {{/if}}
      <div class="map-wrapper">
        <DButton
          class="widget-button btn btn-default btn-show-map btn-small btn-icon-text btn-transparent"
          @action={{this.toggleMap}}
        >
          {{icon "location-dot"}}
          <div class="location-label">
            {{this.userLocation}}
          </div>
          <div class="location-flag">
            {{#if this.showFlag}}
              <NationalFlag @countryCode={{@user.geo_location.countrycode}} />
            {{/if}}
          </div>
        </DButton>
      </div>
    </div>
  </template>
}
