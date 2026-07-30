/* eslint-disable ember/route-path-style -- preserve the existing public URL */

export default function () {
  this.route("locations", function () {
    this.route("users-map", { path: "/users_map" });
  });
}
