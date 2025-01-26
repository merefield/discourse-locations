import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { Input } from "@ember/component";
import { action, computed } from "@ember/object";
import { inject as service } from "@ember/service";
import DButton from "discourse/components/d-button";
import DModal from "discourse/components/d-modal";
import { i18n } from "discourse-i18n";
import I18n from "I18n";
import { htmlSafe } from "@ember/template";
import Form from "discourse/components/form";
import LocationSelector from "./../location-selector";
import ConditionalLoadingSpinner from "discourse/components/conditional-loading-spinner";
import GeoLocationResult from "./../geo-location-result";
// import LocationForm from "./../location-form";


export default class AddLocationComponent extends Component {
  @service siteSettings;
  @tracked flash = this.args.model?.flash;
  @tracked searchOnInit = false;
  @tracked name = null;
  @tracked street = null;
  @tracked postalcode = null;
  @tracked city = null;
  @tracked countrycode = null;
  @tracked geoLocation = { lat: "", lon: "" };
  @tracked rawLocation = null;
  title = I18n.t("composer.location.title");

  constructor() {
    super(...arguments);
    const location = this.args.model.location;

    this.countrycode = this.siteSettings.location_country_default;

    if (location) {
      this.name = location.name;
      this.street = location.street;
      this.neighbourhood = location.neighbourhood;
      this.postalcode = location.postalcode;
      this.city = location.city;
      this.state = location.state;
      this.countrycode = location.countrycode;
      this.geoLocation = location.geo_location;
      this.rawLocation = location.raw;
    }
  }

  @computed()
  get inputFields() {
    return this.siteSettings.location_input_fields.split("|");
  }

  @computed("geoLocation")
  get submitDisabled() {
    return (
      this.siteSettings.location_geocoding === "required" && !this.geoLocation
    );
  }

  @action
  clearModal() {
    this.name = null;
    this.street = null;
    this.neighbourhood = null;
    this.postalcode = null;
    this.city = null;
    this.state = null;
    this.countrycode = null;
    this.geoLocation = { lat: "", lon: "" };
    this.rawLocation = null;
  }

  @action
  clear() {
    this.clearModal();
    this.args.model.update(null);
    this.args.closeModal();
  }

  @action
  submit() {
    if (this.submitDisabled) {
      return;
    }

    let location = {};

    const geocodingEnabled = this.siteSettings.location_geocoding !== "none";
    const inputFields = this.inputFields;
    const hasCoordinates = inputFields.indexOf("coordinates") > -1;

    location["raw"] = this.rawLocation;

    const nonGeoProps = inputFields.filter((f) => f !== "coordinates");

    nonGeoProps.forEach((f) => {
      location[f] = this[f];
    });

    if (geocodingEnabled || hasCoordinates) {
      const geoLocation = this.geoLocation;
      if (geoLocation && geoLocation.lat && geoLocation.lon) {
        location["geo_location"] = geoLocation;
      }
    }

    let name = this.name;

    if (name) {
      location["name"] = name;
    }

    Object.keys(location).forEach((k) => {
      if (location[k] == null || location[k] === "" || location[k] === {}) {
        delete location[k];
      }
    });

    if (Object.keys(location).length === 0) {
      location = null;
    }

    this.args.model.update(location);
    this.clearModal();
    this.args.closeModal();
  }

  @action
  setGeoLocation(gl) {
    this.name = gl.name;
    this.street = gl.street;
    this.neighbourhood = gl.neighbourhood;
    this.postalcode = gl.postalcode;
    this.city = gl.city;
    this.state = gl.state;
    this.geoLocation = { lat: gl.lat, lon: gl.lon };
    this.countrycode = gl.countrycode;
    this.rawLocation = gl.address;
  }

  @action
  searchError(error) {
    this.flash = error;
  }

  <template>
    <DModal
      @closeModal={{@closeModal}}
      @flash={{this.flash}}
      class="add-location add-location-modal"
      @title={{this.title}}
    >
      <div class="location-form">
        <Form
          @onSubmit={{this.submit}}
          @data={{this.formData}}
          as |form transientData|
        >
        {{log this.showAddress}}
          {{#if this.showAddress}}
            <div class="address">
              {{#if this.showInputFields}}
                {{#if this.showTitle}}
                  <div class="title">
                    {{i18n "location.address"}}
                  </div>
                {{/if}}
                {{#if this.showStreet}}
                  <form.Field
                    @name="formStreet"
                    @title={{i18n "location.street.title"}}
                    @format="large"
                    @validation=""
                    @description={{i18n "location.street.desc"}}
                    @disabled={{this.streetDisabled}}
                    as |field|
                  >
                    <field.Input
                    />
                  </form.Field>
                {{/if}}
                {{#if this.showNeighbourhood}}
                  <form.Field
                    @name="formNeighbourhood"
                    @title={{i18n "location.neighbourhood.title"}}
                    @format="large"
                    @validation=""
                    @description={{i18n "location.neighbourhood.desc"}}
                    @disabled={{this.neighbourhoodDisabled}}
                    as |field|
                  >
                    <field.Input
                    />
                  </form.Field>
                {{/if}}
                {{#if this.showPostalcode}}
                  <form.Field
                    @name="formPostalcode"
                    @title={{i18n "location.postalcode.title"}}
                    @format="small"
                    @validation=""
                    @description={{i18n "location.postalcode.desc"}}
                    @disabled={{this.postalcodeDisabled}}
                    as |field|
                  >
                    <field.Input
                    />
                  </form.Field>
                {{/if}}
                {{#if this.showCity}}
                  <form.Field
                    @name="formCity"
                    @title={{i18n "location.city.title"}}
                    @format="large"
                    @validation=""
                    @description={{i18n "location.city.desc"}}
                    @disabled={{this.cityDisabled}}
                    as |field|
                  >
                    <field.Input
                    />
                  </form.Field>
                {{/if}}
                {{#if this.showState}}
                  <form.Field
                    @name="formState"
                    @title={{i18n "location.state.title"}}
                    @format="large"
                    @validation=""
                    @description={{i18n "location.state.desc"}}
                    @disabled={{this.stateDisabled}}
                    as |field|
                  >
                    <field.Input
                    />
                  </form.Field>
                {{/if}}
                {{#if this.showCountrycode}}
                  <form.Field
                    @name="formCountrycode"
                    @title={{i18n "location.country_code.title"}}
                    @format="small"
                    @validation=""
                    @placeholder={{i18n "location.country_code.placeholder"}}
                    @description={{i18n "location.country_code.desc"}}
                    @disabled={{this.countryDisabled}}
                    as |field|
                  > 
                    <field.Select as |select|>
                      {{#each this.countrycodes as |country|}}
                        <select.Option
                          @value={{country.code}}
                        >
                          {{country.name}}
                        </select.Option>
                      {{/each}}
                    </field.Select>
                  </form.Field>
                {{/if}}
              {{else}}
                <form.Field
                  @name="formRawLocation"
                  @title={{i18n "location.query.title"}}
                  @format="large"
                  @validation=""
                  @description={{i18n "location.query.desc"}}
                  @disabled={{this.rawLocationDisabled}}
                  as |field|
                >
                  {{#if this.showGeoLocation}}
                    <field.Custom>
                      <LocationSelector
                        @location={{field.value}}
                        @onChange={{field.set}}
                        class="input-xxlarge location-selector"
                        @searchError={{@searchError}}
                        @context={{this.context}}
                      />
                    </field.Custom>
                    {{!-- <LocationSelector
                      @location={{this.geoLocation}}
                      @onChange={{this.updateGeoLocation}}
                      class="input-xxlarge location-selector"
                      @searchError={{@searchError}}
                      @context={{this.context}}
                    /> --}}
                  {{else}}
                    <field.Input
                    />
                  {{/if}}
                </form.Field>
                  {{!-- </div>
                  <div class="instructions">
                    {{i18n "location.query.desc"}}
                  </div> --}}
                {{!-- </div> --}}
              {{/if}}
              {{#if this.showGeoLocation}}
                {{#if this.showInputFields}}
                  <button
                    class="btn btn-default wizard-btn location-search"
                    onclick={{this.locationSearch}}
                    disabled={{this.searchDisabled}}
                    type="button"
                  >
                    {{i18n "location.geo.btn.label"}}
                  </button>
                  {{#if this.showLocationResults}}
                    <div class="location-results">
                      <h4>{{i18n "location.geo.results"}}</h4>
                      <ul>
                        {{#if this.hasSearched}}
                          <ConditionalLoadingSpinner
                            @condition={{this.loadingLocations}}
                          >
                            {{#each this.geoLocationOptions as |l|}}
                              <GeoLocationResult
                                @updateGeoLocation={{this.updateGeoLocation}}
                                @location={{l}}
                                @geoAttrs={{this.geoAttrs}}
                              />
                            {{else}}
                              <li class="no-results">{{i18n
                                  "location.geo.no_results"
                                }}</li>
                            {{/each}}
                          </ConditionalLoadingSpinner>
                        {{/if}}
                      </ul>
                    </div>
                    {{#if this.showProvider}}
                      <div class="location-form-instructions">{{htmlSafe
                          (i18n "location.geo.desc" provider=this.providerDetails)
                        }}</div>
                    {{/if}}
                  {{/if}}
                {{/if}}
              {{/if}}
            </div>
          {{/if}}
          {{!-- <LocationForm
            @street={{this.street}}
            @neighbourhood={{this.neighbourhood}}
            @postalcode={{this.postalcode}}
            @city={{this.city}}
            @state={{this.state}}
            @countrycode={{this.countrycode}}
            @geoLocation={{this.geoLocation}}
            @rawLocation={{this.rawLocation}}
            @inputFields={{this.inputFields}}
            @searchOnInit={{this.searchOnInit}}
            @setGeoLocation={{this.setGeoLocation}}
            @searchError={{this.searchError}}
          /> --}}
          <hr />
          <form.Field
            @name="formName"
            @title={{i18n "location.name.title"}}
            @format="large"
            @validation=""
            @description={{i18n "location.name.desc"}}
            @disabled={{this.nameDisabled}}
            as |field|
          >
            <field.Input
            />
          </form.Field>
          <form.Submit />
          <form.Reset />
          <form.Cancel />
        </Form> 
        {{!-- <div class="modal-footer">
          <DButton
            id="save-location"
            @action={{action "submit"}}
            @label="location.done"
            @class="btn-primary"
            @disabled={{this.submitDisabled}}
          />
          <DButton
            id="clear-location"
            @class="clear"
            @action={{action "clear"}}
            @label="location.clear"
          /> --}}
      </div>
    </DModal>
  </template>
}
