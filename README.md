# Discourse Locations Plugin

Discourse Locations adds map and geolocation features for topics and users.

It supports:

- Topic-level location data and map rendering.
- Optional user location storage and display across posts, profiles, cards, and a users map.
- Automatic IP-based user location estimation (configurable).

## Features

- Add structured location data to topics (with geocoding support).
- Show map-based topic views, including category map filters and marker behavior controls.
- Support category-level location enablement and category default view as `map`.
- Allow users to set a profile geolocation and optionally show it:
  - In posts (below username)
  - On profile pages
  - In user cards
  - On the users directory map
- Format topic/user location labels with configurable attribute lists.
- Optionally default new topic composer location to the current user's location.
- Validate user profile geolocation updates (requires both `lat` and `lon` when set).
- Keep profile website links opened with `target="_blank"` protected with `noopener noreferrer`.
- Provide canonical users map JSON endpoint at `/locations/users-map.json`.

## Settings

All plugin settings live under the `location_` namespace.

### Core And Input

| Setting                                        | Default                                 | Explanation                                                                                     |
| ---------------------------------------------- | --------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `location_enabled`                             | `true`                                  | Master toggle for the plugin.                                                                   |
| `location_sidebar_menu_map_link`               | `false`                                 | Adds a map link in the sidebar/hamburger menu.                                                  |
| `location_input_fields_enabled`                | `true`                                  | Enables structured location input fields for topic locations.                                   |
| `location_input_fields`                        | `street\|postalcode\|city\|countrycode` | Controls which location attributes are used in topic input/output formatting.                   |
| `location_auto_infer_street_from_address_data` | `false`                                 | Experimental street extraction from provider address responses.                                 |
| `location_geocoding`                           | `optional`                              | Geocoding mode: `none`, `optional`, or `required`.                                              |
| `location_geocoding_language`                  | `user`                                  | Geocoding language (`user` or site default language).                                           |
| `location_geocoding_provider`                  | `nominatim`                             | Geocoding backend (`location_iq`, `mapbox`, `mapquest`, `mapzen`, `nominatim`, `opencagedata`). |
| `location_geocoding_api_key`                   | `""`                                    | API key used by providers that require authentication.                                          |
| `location_geocoding_timeout`                   | `3`                                     | Timeout for geocoding requests.                                                                 |
| `location_geocoding_rate_limit`                | `6`                                     | Geocoding request budget per minute.                                                            |
| `location_geocoding_debounce`                  | `400`                                   | Client debounce interval (ms) before geocoding requests.                                        |

### Map Display And Behavior

| Setting                                                   | Default                                                                        | Explanation                                                             |
| --------------------------------------------------------- | ------------------------------------------------------------------------------ | ----------------------------------------------------------------------- |
| `location_map_tile_layer`                                 | `https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png` | Tile layer URL template for Leaflet maps.                               |
| `location_map_tile_layer_subdomains`                      | `""`                                                                           | Subdomains for the tile layer, if needed by provider.                   |
| `location_map_attribution`                                | OpenStreetMap + CartoDB attribution HTML                                       | Attribution shown on map widgets.                                       |
| `location_category_map_filter`                            | `true`                                                                         | Adds map filter support to location-enabled categories.                 |
| `location_topic_map`                                      | `true`                                                                         | Enables mini-map toggle next to topic location labels.                  |
| `location_topic_status_icon`                              | `false`                                                                        | Enables location status icons in topic lists.                           |
| `location_map_filter_closed`                              | `false`                                                                        | Filters closed topics from map topic lists globally.                    |
| `location_map_zoom`                                       | `2`                                                                            | Default zoom level for general maps.                                    |
| `location_map_marker_zoom`                                | `16`                                                                           | Zoom level used when focusing markers.                                  |
| `location_marker_map_padding_extent`                      | `0.1`                                                                          | Marker viewport padding extent.                                         |
| `location_alternative_marker_map_padding_strategy`        | `false`                                                                        | Uses zoom-out based marker-fit strategy instead of standard padding.    |
| `location_alternative_marker_map_padding_zoom_out_extent` | `0.5`                                                                          | Zoom-out amount used by the alternative padding strategy.               |
| `location_map_marker_cluster_multiplier`                  | `6`                                                                            | Marker cluster distance multiplier.                                     |
| `location_map_marker_category_color`                      | `false`                                                                        | Uses topic category color for map markers.                              |
| `location_map_expanded_zoom`                              | `2`                                                                            | Default zoom for expanded maps.                                         |
| `location_map_center_lat`                                 | `30`                                                                           | Default latitude for map center.                                        |
| `location_map_center_lon`                                 | `5`                                                                            | Default longitude for map center.                                       |
| `location_map_max_topics`                                 | `100`                                                                          | Maximum topics returned to map topic lists.                             |
| `location_map_maker_cluster_enabled`                      | `true`                                                                         | Enables map marker clustering.                                          |
| `location_layouts_map_search_enabled`                     | `false`                                                                        | Enables layouts-map search (requires Layouts plugin).                   |
| `location_layouts_map_show_avatar`                        | `false`                                                                        | Shows avatar in layouts-map widget (requires Layouts plugin).           |
| `location_hide_labels`                                    | `false`                                                                        | Hides marker tooltip labels.                                            |
| `location_short_names`                                    | `false`                                                                        | Topic locations show only location name (omit address).                 |
| `location_add_no_text`                                    | `false`                                                                        | Removes text labels from add-location buttons.                          |
| `location_nearby_list_max_distance_km`                    | `0`                                                                            | Experimental nearby-topic list radius in km (`0` disables nearby list). |

### User Location And Users Map

| Setting                        | Default | Explanation                                                     |
| ------------------------------ | ------- | --------------------------------------------------------------- |
| `location_users_map`           | `false` | Enables user geolocation and users map features.                |
| `location_user_avatar`         | `false` | Shows user avatars on users-map markers.                        |
| `location_users_map_limit`     | `50`    | Max users shown in one users-map response.                      |
| `location_users_map_default`   | `false` | Makes users map the default Users directory view.               |
| `location_user_post`           | `false` | Shows a user's location under username in posts.                |
| `location_user_country_flag`   | `true`  | Shows country flag with user location on profile/card.          |
| `location_user_post_format`    | `""`    | Format list for post location label (e.g. `city\|countrycode`). |
| `location_user_profile_map`    | `true`  | Enables mini-map toggle next to user location on profile/card.  |
| `location_user_profile_format` | `""`    | Format list for profile/card location label.                    |

### Defaults

| Setting                                          | Default | Explanation                                          |
| ------------------------------------------------ | ------- | ---------------------------------------------------- |
| `location_country_default`                       | `""`    | Default country for location input/search.           |
| `location_country_default_apply_to_all_searches` | `false` | Applies default country restriction to all searches. |
| `location_topic_default`                         | `none`  | Default topic location source (`none` or `user`).    |

### Automated IP Lookup

| Setting                                               | Default    | Explanation                                                           |
| ----------------------------------------------------- | ---------- | --------------------------------------------------------------------- |
| `location_ip_auto_lookup_mode`                        | `disabled` | Auto-lookup trigger mode: `disabled`, `posting`, `login_and_posting`. |
| `location_ip_granularity`                             | `city`     | Output granularity: `country`, `province`, `county`, or `city`.       |
| `location_ip_lookup_cooldown_days`                    | `1`        | Minimum days between automatic lookups per user.                      |
| `locations_skip_ip_based_location_update_if_existing` | `true`     | Skips auto-update when user already has `lat`/`lon`.                  |
| `location_geonames_username`                          | `""`       | GeoNames username used to resolve geographic feature details.         |
| `location_ip_lookup_debug_logging`                    | `false`    | Emits warn-level debug logs for IP lookup pipeline.                   |

## Automated User Location Determination (IP Based)

This plugin can automatically infer and persist user location data from IP intelligence.

### When It Runs

Automatic lookup only runs when all of the following are true:

- `location_enabled` is enabled.
- `location_users_map` is enabled.
- `location_ip_auto_lookup_mode` is not `disabled`.
- `location_geonames_username` is set.
- Environment variables are set:
  - `DISCOURSE_MAXMIND_ACCOUNT_ID`
  - `DISCOURSE_MAXMIND_LICENSE_KEY`

Trigger behavior:

- `posting`: enqueue lookup when a user creates a post.
- `login_and_posting`: enqueue on post creation and on user login.

### Lookup Pipeline

1. Select IP source (post IP/login token IP/user IP fallback).
2. Query MaxMind via `DiscourseIpInfo.get`.
3. Choose a GeoNames feature by configured granularity.
4. Build normalized `geo_location` payload (`lat`, `lon`, `address`, country/state/city metadata).
5. Save user custom field and upsert users-map location record.

### Safeguards

- Cooldown enforced by `location_ip_lookup_cooldown_days`.
- Existing coordinate protection controlled by `locations_skip_ip_based_location_update_if_existing`.
- Granularity controls how precise the stored location is.
- Debug logging can be enabled with `location_ip_lookup_debug_logging`.

### Operational Notes

- Precision depends on IP quality and chosen granularity.
- For privacy-sensitive communities, prefer coarser granularity (`country`/`province`) and longer cooldowns.
- Users can still clear or replace their location through profile preferences.

## Behavior Covered By Specs

Current system/request specs cover:

- User geolocation validation and clearing behavior during profile updates.
- Topic create/update persistence for `location` and `has_geo_location` custom fields.
- Users map rendering with marker presence.
- Profile and user-card location rendering (including formatted label text).
- Profile and card website rendering in plugin replacement UI.
- Composer defaulting topic location from user location when configured.
- Category default view as `map` without route errors.
- Canonical users map endpoint behavior.

## Discuss The Plugin

Community discussion and support thread:

- https://meta.discourse.org/t/locations-plugin/69742?u=merefield

## Support This Work

If this plugin helps your community, please consider supporting ongoing maintenance and new feature development:

- https://github.com/sponsors/merefield
