import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { array } from "@ember/helper";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DMultiSelect from "discourse/components/d-multi-select";
import { escapeExpression } from "discourse/lib/utilities";
import { i18n } from "discourse-i18n";
import {
  geoLocationFormat,
  geoLocationSearch,
  providerDetails,
} from "../lib/location-utilities";

/**
 * Location selector component using DMultiSelect for autocomplete functionality
 *
 * @component LocationSelector
 * @param {Object} @location - Current location object with address property
 * @param {string} @context - Context for location search
 * @param {Array} @geoAttrs - geoAttrs to be passed into geoLocationFormat function
 * @param {boolean} @showType - Whether to show location type in results
 * @param {function} @onChangeCallback - Callback when location changes
 */
export default class LocationSelector extends Component {
  @service siteSettings;
  @service site;

  @tracked selectedLocation = null;
  @tracked loading = false;
  @tracked currentProvider = null;

  constructor() {
    super(...arguments);
    this.initializeLocation();
  }

  initializeLocation() {
    const locationAddress = this.args.location?.address;
    if (locationAddress) {
      // Create a location object from the existing address
      this.selectedLocation = {
        address: locationAddress,
        id: locationAddress, // Use address as ID for comparison
      };
    }
  }

  get loadFn() {
    return async (term) => {
      if (!term || term.length === 0) {
        return [];
      }

      let request = { query: term };

      const context = this.args.context;
      if (context) {
        request["context"] = context;
      }

      this.loading = true;

      try {
        const result = await geoLocationSearch(
          request,
          this.siteSettings.location_geocoding_debounce
        );

        if (result.error) {
          throw new Error(result.error);
        }

        const defaultProvider = this.siteSettings.location_geocoding_provider;
        const geoAttrs = this.args.geoAttrs;
        const showType = this.args.showType;
        let locations = [];

        // Store current provider for display
        this.currentProvider =
          providerDetails[result.provider || defaultProvider];

        if (!result.locations || result.locations.length === 0) {
          locations = [];
        } else {
          locations = result.locations.map((l) => {
            if (geoAttrs) {
              l["geoAttrs"] = geoAttrs;
            }
            if (showType !== undefined) {
              l["showType"] = showType;
            }
            // Ensure each location has an ID for comparison
            l.id = l.address || JSON.stringify(l);
            return l;
          });
        }

        // Add provider info as non-selectable display item
        if (this.currentProvider) {
          locations.push({
            provider: this.currentProvider,
            address: i18n("location.geo.desc", {
              provider: this.currentProvider,
            }),
          });
        }

        return locations;
      } catch (e) {
        if (this.searchError) {
          this.searchError(e);
        }
        return [];
      } finally {
        this.loading = false;
      }
    };
  }

  @action
  handleSelectionChange(selectedLocations) {
    // Only handle single selection
    const location = selectedLocations?.[selectedLocations.length - 1];

    if (!location) {
      this.selectedLocation = null;
      // Don't call onChangeCallback with null - original implementation
      // only called callback when selecting valid location objects
      return;
    }

    // Don't select special items (a location with provider prop is there for display only)
    if (location.provider) {
      return;
    }

    this.selectedLocation = location;

    if (this.args.onChangeCallback) {
      this.args.onChangeCallback(location);
    }
  }

  @action
  compareLocations(a, b) {
    if (!a || !b) {
      return false;
    }
    return a.id === b.id || a.address === b.address;
  }

  getDisplayText(location) {
    if (!location) {
      return "";
    }

    const geoAttrs = this.args.geoAttrs;
    if (typeof location === "object" && location.address) {
      return geoLocationFormat(location, this.site.country_codes, { geoAttrs });
    }

    return location.address || location.toString();
  }

  <template>
    <div class="location-selector-wrapper" ...attributes>
      {{#if this.loading}}
        <span class="ac-loading">
          <div class="spinner small"></div>
        </span>
      {{/if}}

      <DMultiSelect
        @selection={{if
          this.selectedLocation
          (array this.selectedLocation)
          (array)
        }}
        @loadFn={{this.loadFn}}
        @onChange={{this.handleSelectionChange}}
        @label={{@placeholder}}
        @compareFn={{this.compareLocations}}
        @placement="bottom-start"
        @allowedPlacements={{array "top-start" "bottom-start"}}
        @matchTriggerWidth={{true}}
        @matchTriggerMinWidth={{true}}
        class="location-selector"
      >
        <:selection as |location|>
          {{this.getDisplayText location}}
        </:selection>

        <:result as |location|>
          {{#if location.provider}}
            <div class="location-provider">
              <label>{{{location.address}}}</label>
            </div>
          {{else}}
            <div class="location-form-result">
              <label>{{escapeExpression location.address}}</label>
              {{#if location.showType}}
                {{#if location.type}}
                  <div class="location-type">{{escapeExpression
                      location.type
                    }}</div>
                {{/if}}
              {{/if}}
            </div>
          {{/if}}
        </:result>

      </DMultiSelect>
    </div>
  </template>
}
