import Component from "@glimmer/component";
import { action } from "@ember/object";
import { i18n } from "discourse-i18n";

export default class SetLocationUpsert extends Component {
  static shouldRender(args, context) {
    return context.siteSettings.enable_simplified_category_creation;
  }

  get locationEnabled() {
    return this.customFieldEnabled("location_enabled");
  }

  get locationTopicStatus() {
    return this.customFieldEnabled("location_topic_status");
  }

  get locationMapFilterClosed() {
    return this.customFieldEnabled("location_map_filter_closed");
  }

  customFieldEnabled(name) {
    const fieldName = name.split(".").pop();
    const value =
      this.args.outletArgs.transientData?.custom_fields?.[fieldName];
    return value?.toString() === "true";
  }

  @action
  async onToggle(_, { set, name }) {
    await set(name, this.customFieldEnabled(name) ? "false" : "true");
  }

  <template>
    {{#let @outletArgs.form as |form|}}
      <form.Section @title={{i18n "category.location_settings_label"}}>
        <form.Object @name="custom_fields" as |customFields|>
          <customFields.Field
            @name="location_enabled"
            @title={{i18n "category.location_enabled"}}
            @onSet={{this.onToggle}}
            @type="checkbox"
            as |field|
          >
            <field.Control checked={{this.locationEnabled}} />
          </customFields.Field>

          <customFields.Field
            @name="location_topic_status"
            @title={{i18n "category.location_topic_status"}}
            @onSet={{this.onToggle}}
            @type="checkbox"
            as |field|
          >
            <field.Control checked={{this.locationTopicStatus}} />
          </customFields.Field>

          <customFields.Field
            @name="location_map_filter_closed"
            @title={{i18n "category.location_map_filter_closed"}}
            @onSet={{this.onToggle}}
            @type="checkbox"
            as |field|
          >
            <field.Control checked={{this.locationMapFilterClosed}} />
          </customFields.Field>
        </form.Object>
      </form.Section>
    {{/let}}
  </template>
}
