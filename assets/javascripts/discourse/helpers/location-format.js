import { htmlSafe } from "@ember/template";
import Site from "discourse/models/site";
import { locationFormat } from "../lib/location-utilities";
import { helperContext } from "discourse-common/lib/helpers";

export default function _locationFormat(location, opts) {
  let siteSettings = helperContext().siteSettings;
  return htmlSafe(
    locationFormat(
      location,
      Site.currentProp("country_codes"),
      siteSettings.location_input_fields_enabled,
      siteSettings.location_input_fields,
      siteSettings.location_short_names,
      { ...opts }
    )
  );
}
