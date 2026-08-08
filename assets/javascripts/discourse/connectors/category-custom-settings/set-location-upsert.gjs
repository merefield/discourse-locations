import Component from "@glimmer/component";
import { action } from "@ember/object";
import { i18n } from "discourse-i18n";
import { CATEGORY_LOCATION_SETTINGS } from "discourse/plugins/discourse-locations/discourse/lib/category-location-settings";

export default class SetLocationUpsert extends Component {
  static shouldRender(args, context) {
    return context.siteSettings.enable_simplified_category_creation;
  }

  customFieldEnabled = (name) => {
    const fieldName = name.split(".").pop();
    const value =
      this.args.outletArgs.transientData?.custom_fields?.[fieldName];
    return value?.toString() === "true";
  };

  get categoryLocationSettings() {
    return CATEGORY_LOCATION_SETTINGS;
  }

  @action
  async onToggle(_, { set, name }) {
    await set(name, this.customFieldEnabled(name) ? "false" : "true");
  }

  <template>
    {{#let @outletArgs.form as |form|}}
      <form.Section @title={{i18n "category.location_settings_label"}}>
        <form.Object @name="custom_fields" as |customFields|>
          {{#each this.categoryLocationSettings as |setting|}}
            <customFields.Field
              @name={{setting.key}}
              @title={{i18n setting.label}}
              @onSet={{this.onToggle}}
              @type="checkbox"
              as |field|
            >
              <field.Control checked={{this.customFieldEnabled setting.key}} />
            </customFields.Field>
          {{/each}}
        </form.Object>
      </form.Section>
    {{/let}}
  </template>
}
