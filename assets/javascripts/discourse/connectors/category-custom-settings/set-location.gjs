import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { i18n } from "discourse-i18n";
import { CATEGORY_LOCATION_SETTINGS } from "discourse/plugins/discourse-locations/discourse/lib/category-location-settings";

export default class SetLocation extends Component {
  static shouldRender(args, context) {
    return !context.siteSettings.enable_simplified_category_creation;
  }

  customFieldEnabled = (key) => {
    return (
      this.args.outletArgs.category.custom_fields?.[key]?.toString() === "true"
    );
  };

  get categoryLocationSettings() {
    return CATEGORY_LOCATION_SETTINGS;
  }

  @action
  onToggle(key, event) {
    this.args.outletArgs.category.custom_fields[key] = event.target.checked;
  }

  <template>
    <section>
      <h3>{{i18n "category.location_settings_label"}}</h3>

      {{#each this.categoryLocationSettings as |setting|}}
        <section class="field">
          <label>
            <input
              type="checkbox"
              checked={{this.customFieldEnabled setting.key}}
              {{on "change" (fn this.onToggle setting.key)}}
            />
            {{i18n setting.label}}
          </label>
        </section>
      {{/each}}
    </section>
  </template>
}
