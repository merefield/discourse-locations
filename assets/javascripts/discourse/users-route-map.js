/* eslint-disable ember/route-path-style */
export default function () {
  this.route("locations", function () {
    this.route("users-map", { path: "/users_map" });
  });
}
