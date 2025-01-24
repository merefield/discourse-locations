import Component from "@glimmer/component";
import LocationLabelContainer from "../../components/location-label-container";

export default class LocationLabel extends Component {
  <template>
    {{#if @outletArgs.topic.location}}
      <span class="location-after-title">
        <LocationLabelContainer
          @topic={{@outletArgs.topic}}
          @parent="topic-list"
        />
      </span>
    {{/if}}
  </template>
}
