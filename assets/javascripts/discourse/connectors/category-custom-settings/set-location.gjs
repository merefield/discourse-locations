import { Input } from "@ember/component";
import { i18n } from "discourse-i18n";

export default <template>
  <section>
    <h3>{{i18n "category.location_settings_label"}}</h3>

    <section class="field">
      <label>
        <Input
          @type="checkbox"
          @checked={{@outletArgs.category.custom_fields.location_enabled}}
        />
        {{i18n "category.location_enabled"}}
      </label>
    </section>

    <section class="field">
      <label>
        <Input
          @type="checkbox"
          @checked={{@outletArgs.category.custom_fields.location_topic_status}}
        />
        {{i18n "category.location_topic_status"}}
      </label>
    </section>

    <section class="field">
      <label>
        <Input
          @type="checkbox"
          @checked={{@outletArgs.category.custom_fields.location_map_filter_closed}}
        />
        {{i18n "category.location_map_filter_closed"}}
      </label>
    </section>
  </section>
</template>
