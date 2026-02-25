import Component from "@glimmer/component";
import { LinkTo } from "@ember/routing";
import { service } from "@ember/service";
import { i18n } from "discourse-i18n";

export default class UsersTopMapLink extends Component {
  @service siteSettings;

  <template>
    {{#if this.siteSettings.location_users_map}}
      <div class="container users-nav">
        <ul class="nav nav-pills">
          <li>
            <LinkTo @route="users">
              {{i18n "directory.list.title"}}
            </LinkTo>
          </li>
          <li>
            <LinkTo @route="locations.users-map">
              {{i18n "directory.map.title"}}
            </LinkTo>
          </li>
          <li>
            <a
              href="/my/preferences/profile"
              title={{i18n "directory.map.user_prefs_link.title"}}
            >{{i18n "directory.map.user_prefs_link.text"}}</a>
          </li>
        </ul>
      </div>
    {{/if}}
  </template>
}
