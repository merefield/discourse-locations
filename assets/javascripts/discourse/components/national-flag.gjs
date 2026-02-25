import Component from "@glimmer/component";

export default class NationalFlagComponent extends Component {
  get fileName() {
    return (
      "/plugins/discourse-locations/images/nationalflags/" +
      this.args.countryCode.toLowerCase() +
      ".png"
    );
  }

  <template><img class="national-flag" src={{this.fileName}} /></template>
}
