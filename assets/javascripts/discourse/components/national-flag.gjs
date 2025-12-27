import Component from "@glimmer/component";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import { relativeAge } from "discourse/lib/formatter";
import icon from "discourse-common/helpers/d-icon";
import { i18n } from "discourse-i18n";

export default class NationalFlagComponent extends Component {
  get fileName() {
    return (
      "/plugins/discourse-locations/images/nationalflags/" +
      this.args.countryCode +
      ".png"
    );
  }

  <template>
    <img class="national-flag" src={{this.fileName}} />
  </template>
}
