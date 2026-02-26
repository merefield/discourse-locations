import Component from "@glimmer/component";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import dIcon from "discourse/helpers/d-icon";
import UserLocation from "../../components/user-location";

export default class UserCardReplaceLocation extends Component {
  get showUserLocation() {
    return !!this.args.outletArgs.user?.geo_location;
  }

  get linkWebsite() {
    return !this.args.outletArgs.user?.isBasic;
  }

  @action
  decorateLocationAndWebsite(element) {
    const wrapper = element.closest(".location-and-website");
    if (wrapper) {
      wrapper.classList.add("map-location-enabled");
    }
  }

  <template>
    <div class="replace-location">
      <span hidden {{didInsert this.decorateLocationAndWebsite}}></span>

      {{#if this.showUserLocation}}
        <span class="location">
          <UserLocation @user={{@outletArgs.user}} @formFactor="card" />
        </span>
      {{/if}}

      {{#if @outletArgs.user.website_name}}
        <span class="website-name">
          {{dIcon "globe"}}
          {{#if this.linkWebsite}}
            <a
              href={{@outletArgs.user.website}}
              rel="nofollow ugc noopener noreferrer"
              target="_blank"
            >
              {{@outletArgs.user.website_name}}
            </a>
          {{else}}
            <span title={{@outletArgs.user.website}}>
              {{@outletArgs.user.website_name}}
            </span>
          {{/if}}
        </span>
      {{/if}}
    </div>
  </template>
}
