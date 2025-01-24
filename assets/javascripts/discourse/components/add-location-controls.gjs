import Component from "@glimmer/component";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import { service } from "@ember/service";
import $ from "jquery";
import DButton from "discourse/components/d-button";
import AddLocationComponent from "../components/modal/add-location";
import { locationFormat } from "../lib/location-utilities";

export default class AddLocationControlsComponent extends Component {
  @service modal;
  @service siteSettings;
  @service site;

  @action
  didInsert() {
    $(".title-and-category").toggleClass("location-add-no-text", this.iconOnly);
  }

  get iconOnly() {
    return this.args.noText || this.siteSettings.location_add_no_text;
  }

  get valueClasses() {
    let classes = "add-location-btn";
    if (this.args.noText) {
      classes += " btn-primary";
    }
    return classes;
  }

  get valueLabel() {
    return this.args.noText
      ? ""
      : locationFormat(
          this.args.location,
          this.site.country_codes,
          this.siteSettings.location_input_fields_enabled,
          this.siteSettings.location_input_fields
        );
  }

  get addLabel() {
    return this.args.noText ? "" : "composer.location.btn";
  }

  @action
  showAddLocation() {
    return this.modal.show(AddLocationComponent, {
      model: {
        location: this.args.location,
        categoryId: this.args.category.id,
        update: (location) => {
          if (this._state !== "destroying") {
            this.args.updateLocation(location);
          }
        },
      },
    });
  }

  @action
  removeLocation() {
    this.location = null;
    this.args.updateLocation(location);
  }

  <template>
    <div class="location-label" {{didInsert this.didInsert}}>
      {{#if @location}}
        <DButton
          @class={{this.valueClasses}}
          @title="location.label.add"
          @action={{action "showAddLocation"}}
          @translatedLabel={{this.valueLabel}}
          @icon="location-dot"
        />
        {{#unless @noText}}
          <DButton
            @icon="xmark"
            @action={{action "removeLocation"}}
            @class="remove"
          />
        {{/unless}}
      {{else}}
        {{#if this.iconOnly}}
          <DButton
            @class="add-location-btn"
            @icon="location-dot"
            @action={{action "showAddLocation"}}
            @title={{this.addLabel}}
          />
        {{else}}
          <DButton
            @class="add-location-btn"
            @icon="location-dot"
            @label={{this.addLabel}}
            @action={{action "showAddLocation"}}
            @title={{this.addLabel}}
          />
        {{/if}}
      {{/if}}
    </div>
  </template>
}
