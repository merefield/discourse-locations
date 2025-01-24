import Component from "@glimmer/component";
import icon from "discourse-common/helpers/d-icon";
import LocationLabelContainer from "../../components/location-label-container";
import locationFormat from "../../helpers/location-format";

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
