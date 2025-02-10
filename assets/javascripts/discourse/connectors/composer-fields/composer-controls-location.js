import { set } from "@ember/object";

export default {
  actions: {
    updateLocation(location) {
      set(this.model, "location", location);
    },
  },
};
