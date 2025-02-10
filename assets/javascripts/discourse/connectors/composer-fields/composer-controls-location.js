import { set } from "@ember/object";

export default {
  actions: {
    updateLocation(location) {
      set("model.location", location);
    },
  },
};
