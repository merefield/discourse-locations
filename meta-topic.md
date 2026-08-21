| | | |
| - | - | - |
| :information_source: | **Summary** | A Discourse plugin that adds structured and geocoded topic and user locations with map-based discovery |
| :hammer_and_wrench: | **Repository Link** | <https://github.com/merefield/discourse-locations> |
| :open_book: | **Install Guide** | [How to install plugins in Discourse](https://meta.discourse.org/t/install-plugins-in-discourse/19157) |
| :heart: | **Sponsorship** | Please consider becoming an ongoing [sponsor of my open source work](https://github.com/sponsors/merefield) at a level that suits your or your organisation's resources and needs to ensure this plugin gets the maintenance it deserves and continues to work for your site in the future. |

Enjoying this plugin? Please :star: it on [GitHub](https://github.com/merefield/discourse-locations)! :pray:

### Features

Discourse Locations provides the complete location-storage, geocoding, and map foundation. The optional Pro extension adds advanced discovery, automation, and users-map presentation while requiring this base plugin.

| Feature | Base plugin | Pro extension |
| --- | --- | --- |
| Structured topic locations and configurable input fields | :white_check_mark: | — |
| Optional or required geocoding with multiple providers | :white_check_mark: | — |
| Category and site-wide topic map views | :white_check_mark: | — |
| User locations on posts, profiles, cards, and the directory map | :white_check_mark: | — |
| Leaflet users map with local name and username search | :white_check_mark: | — |
| Configurable location labels, flags, map markers, clustering, and tiles | :white_check_mark: | — |
| Default a new topic to the current user's location | :white_check_mark: | — |
| Automated IP-based user-location estimation | — | :white_check_mark: **Exclusive** |
| Nearby-topic discovery based on the current user's location | — | :white_check_mark: **Exclusive** |
| Optional location-aware `discourse-chatbot` tools | — | :white_check_mark: **Exclusive** |
| Permission-aware group and result-limit users-map filters | — | :white_check_mark: **Exclusive** |
| Interactive WebGL users-map globe | — | :white_check_mark: **Exclusive** |
| Idle globe screen saver | — | :white_check_mark: **Exclusive** |

Installing Pro adds its exclusive features to the base functionality; it does not replace the base plugin.

### Configuration

The base plugin's settings use the `location_` prefix and control topic locations, geocoding, map display, user locations, and the standard users map.

Useful documentation:

* [Administration settings](https://coop.pavilion.tech/docs?topic=1620)
* [Locations in topics](https://coop.pavilion.tech/docs?topic=1763)
* [Locations in categories](https://coop.pavilion.tech/docs?topic=1550)

### Privacy and storage

Users choose whether to save a profile location. Complete editable topic and user locations remain in base-owned custom fields, while plugin-owned projection tables support spatial queries and map ordering.

Raw location custom fields are not made globally public. Topic, profile, card, post, and directory responses expose only the location data required by that surface and respect Discourse's profile and group visibility rules.

### Pro extension

[Discourse Locations Pro](https://github.com/merefield/discourse-locations-pro-ext) is an optional extension available to GitHub Sponsors as a thank-you for supporting ongoing development. Individual and independent-community sponsors receive access from the **$7/month Bronze tier**; businesses and institutions must sponsor at the **$40/month Silver tier** or above. Eligible sponsors receive private-repository installation instructions.

The Pro extension adds automated IP lookup, Nearby topics, Chatbot tools, enhanced users-map filters, the interactive globe, and the globe screen saver. Each optional automation or integration remains disabled until configured, and the Pro master setting can disable all Pro behaviour without disabling the base plugin.

**[Sponsor on GitHub to get Locations Pro](https://github.com/sponsors/merefield)**
