import Layout from "discourse/components/discovery/layout";
import Navigation from "discourse/components/discovery/navigation";
import LocationsMap from "discourse/plugins/discourse-locations/discourse/components/locations-map";

export default <template>
  <Layout
    @model={{@controller.model}}
    @createTopicDisabled={{@controller.createTopicDisabled}}
  >
    <:navigation>
      <Navigation
        @category={{@controller.model.category}}
        @tag={{@controller.model.tag}}
        @additionalTags={{@controller.model.additionalTags}}
        @filterType={{@controller.model.filterType}}
        @noSubcategories={{@controller.model.noSubcategories}}
        @canBulkSelect={{@controller.canBulkSelect}}
        @bulkSelectHelper={{@controller.bulkSelectHelper}}
        @createTopic={{@controller.createTopic}}
        @createTopicDisabled={{@controller.createTopicDisabled}}
        @canCreateTopicOnTag={{@controller.canCreateTopicOnTag}}
        @toggleTagInfo={{@controller.toggleTagInfo}}
        @tagNotification={{@controller.tagNotification}}
      />
    </:navigation>

    <:list>
      <div class="map-component map-container">
        <LocationsMap
          @mapType="topicList"
          @category={{@controller.model.category}}
        />
      </div>
    </:list>
  </Layout>
</template>
