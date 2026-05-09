import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import willDestroy from "@ember/render-modifiers/modifiers/will-destroy";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";
import locationFormat from "../helpers/location-format";
import LocationsMap from "./locations-map";
import LocationsTopicMapModal from "./modal/locations-topic-map-modal";

export default class LocationLableContainerComponent extends Component {
  @service siteSettings;
  @service site;
  @service modal;

  @tracked locationAttrs = [];
  @tracked geoAttrs = [];
  @tracked showMap = false;

  outsideClick = (e) => {
    if (
      !this.isDestroying &&
      !(
        e.target.closest(".map-expand") ||
        e.target.closest(".map-attribution") ||
        e.target.closest(".location-topic-map") ||
        e.target.closest("#locations-map")
      )
    ) {
      this.showMap = false;
    }
  };

  @action
  showTopicMapModal() {
    this.modal.show(LocationsTopicMapModal, {
      model: {
        topic: this.args.topic,
      },
    });
  }

  get mapButtonLabel() {
    return `location.geo.${this.showMap ? "hide" : "show"}_map`;
  }

  get showMapButtonLabel() {
    return !this.site.mobileView;
  }

  get showMapToggle() {
    return (
      this.args?.topic?.location?.geo_location &&
      this.siteSettings.location_topic_map &&
      this.args.parent !== "topic-list"
    );
  }

  get opts() {
    let opts = {};
    if (this.locationAttrs) {
      opts["attrs"] = this.locationAttrs;
    }
    if (this.geoAttrs) {
      opts["geoAttrs"] = this.geoAttrs;
    }
    return opts;
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
      class="location-label-container"
    >
      <div class="location-label" title={{i18n "location.label.title"}}>
        <span class="location-text">
          {{#if this.showMapToggle}}
            {{icon "location-dot"}}{{locationFormat @topic.location this.opts}}
          {{else}}
            <DButton
              @action={{this.showTopicMapModal}}
              @icon="location-dot"
              class="btn btn-small btn-transparent"
            ><span class="label-text">{{locationFormat
                  @topic.location
                  this.opts
                }}</span>
            </DButton>
          {{/if}}
        </span>
      </div>

      {{#if this.showMapToggle}}
        <div class="location-topic-map">
          <DButton
            @action={{this.toggleMap}}
            class="btn btn-small btn-default"
            @icon="far-map"
            @label={{if this.showMapButtonLabel this.mapButtonLabel}}
          />
        </div>
        {{#if this.showMap}}
          <div class="map-component map-container small">
            <LocationsMap @topic={{@topic}} @mapType="topic" />
          </div>
        {{/if}}
      {{/if}}
    </div>
  </template>
}
