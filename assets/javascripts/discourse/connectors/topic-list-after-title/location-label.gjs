import Component from "@glimmer/component";
import locationFormat from "../../helpers/location-format";
import LocationLabelContainer from  "../../components/location-label-container";
import icon from "discourse-common/helpers/d-icon";

export default class LocationLabel extends Component {
  <template>
    {{#if @outletArgs.topic.location}}
      <span class="location-after-title">
        <LocationLabelContainer @topic={{@outletArgs.topic}} @parent={{"topic-list"}}/>
      </span>
    {{/if}}
  </template> 
}
