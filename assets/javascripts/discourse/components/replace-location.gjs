import Component from "@glimmer/component";
import { service } from "@ember/service";
import bodyClass from "discourse/helpers/body-class";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import UserLocation from "./user-location";

export default class ReplaceLocationComponent extends Component {
  @service siteSettings;

  get showUserLocation() {
    return !!this.args.model.geo_location;
  }

  get linkWebsite() {
    return !this.args.model.isBasic;
  }

  get removeNoFollow() {
    return (
      this.args.model.trust_level > 2 && !this.siteSettings.tl3_links_no_follow
    );
  }

  <template>
    {{bodyClass "map-location-enabled"}}
    <div class="replace-location">
      {{#if this.showUserLocation}}
        <div class="user-profile-location">
          <UserLocation @user={{@model}} @formFactor="profile" />
        </div>
      {{/if}}
      {{#if @model.website_name}}
        <div class="user-profile-website">
          {{dIcon "globe"}}
          {{#if this.linkWebsite}}
            {{! eslint-disable ember/template-link-rel-noopener }}
            <a
              href={{@model.website}}
              rel={{if
                this.removeNoFollow
                "noopener noreferrer"
                "nofollow ugc noopener noreferrer"
              }}
              target="_blank"
            >
              {{@model.website_name}}
            </a>
            {{! eslint-enable ember/template-link-rel-noopener }}
          {{else}}
            <span title={{@model.website}}>{{@model.website_name}}</span>
          {{/if}}
        </div>
      {{/if}}
    </div>
  </template>
}
