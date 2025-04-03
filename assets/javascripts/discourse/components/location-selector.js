import $ from "jquery";
import TextField from "discourse/components/text-field";
import { observes } from "discourse/lib/decorators";
import { escapeExpression } from "discourse/lib/utilities";
import { i18n } from "discourse-i18n";
import {
  geoLocationFormat,
  geoLocationSearch,
  providerDetails,
} from "../lib/location-utilities";

export default TextField.extend({
  autocorrect: false,
  autocapitalize: false,
  classNames: "location-selector",
  context: null,
  size: 400,

  didInsertElement() {
    this._super();
    let self = this;
    const location = this.get("location.address");

    let val = "";
    if (location) {
      val = location;
    }

    $(self.element)
      .val(val)
      .autocomplete({
        template: locationAutocompleteTemplate,
        single: true,
        updateData: false,

        dataSource: function (term) {
          let request = { query: term };

          const context = self.get("context");
          if (context) {
            request["context"] = context;
          }

          self.set("loading", true);

          return geoLocationSearch(
            request,
            self.siteSettings.location_geocoding_debounce
          )
            .then((result) => {
              if (result.error) {
                throw new Error(result.error);
              }

              const defaultProvider =
                self.siteSettings.location_geocoding_provider;
              const geoAttrs = self.get("geoAttrs");
              const showType = self.get("showType");
              let locations = [];

              if (!result.locations || result.locations.length === 0) {
                locations = [
                  {
                    no_results: true,
                  },
                ];
              } else {
                locations = result.locations.map((l) => {
                  if (geoAttrs) {
                    l["geoAttrs"] = geoAttrs;
                  }
                  if (showType !== undefined) {
                    l["showType"] = showType;
                  }
                  return l;
                });
              }

              locations.push({
                provider: providerDetails[result.provider || defaultProvider],
              });

              self.set("loading", false);

              return locations;
            })
            .catch((e) => {
              self.set("loading", false);
              this.searchError(e);
            });
        },

        transformComplete: function (l) {
          if (typeof l === "object") {
            self.onChangeCallback(l);
            const geoAttrs = self.get("geoAttrs");
            return geoLocationFormat(l, self.site.country_codes, { geoAttrs });
          } else {
            // hack to get around the split autocomplete performs on strings
            document
              .querySelectorAll(".location-form .ac-wrap .item")
              .forEach((element) => {
                element.remove();
              });
            document
              .querySelectorAll(".user-location-selector .ac-wrap .item")
              .forEach((element) => {
                element.remove();
              });
            return self.element.value;
          }
        },

        onChangeItems: function (items) {
          if (items[0] == null) {
            self.set("location", "{}");
          }
        },
      });
  },

  @observes("loading")
  showLoadingSpinner() {
    const loading = this.get("loading");
    const wrap = this.element.parentNode;
    const spinner = document.createElement("span");
    spinner.className = "ac-loading";
    spinner.innerHTML = "<div class='spinner small'></div>";
    if (loading) {
      wrap.insertBefore(spinner, wrap.firstChild);
    } else {
      const existingSpinner = wrap.querySelectorAll(".ac-loading");
      existingSpinner.forEach((el) => el.remove());
    }
  },

  willDestroyElement() {
    this._super();
    $(this.element).autocomplete("destroy");
  },
});

function locationAutocompleteTemplate(context) {
  const optionHtml = context.options.map((o) => {
    if (o.no_results) {
      return `<div class="no-results">${i18n("location.geo.no_results")}</div>`;
    } else if (o.provider) {
      return `<label>${i18n("location.geo.desc", {
        provider: o.provider,
      })}</label>`;
    } else {
      const typeHtml = o.showType
        ? `<div class="location-type">${escapeExpression(o.type)}</div>`
        : "";

      return `
        <li class="location-form-result">
          <label>${escapeExpression(o.address)}</label>
          ${typeHtml}
        </li>`;
    }
  });
  return `<div class="autocomplete"><ul>${optionHtml.join("")}</ul></div>`;
}
