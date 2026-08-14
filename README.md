# Discourse Locations

Discourse Locations adds structured and geocoded locations to topics and users, with map-based discovery throughout Discourse.

## Functionality

- Adds structured locations to topics, including optional or required geocoding.
- Enables locations per category and supports category and site-wide topic map views.
- Provides configurable map markers, clustering, labels, bounds, default centres, and tile providers.
- Lets users save a voluntary profile location and optionally show it on posts, profiles, user cards, and the users directory map.
- Supports configurable location formats, country flags, profile maps, and defaulting a new topic to the current user's location.
- Includes local name and username search on the users map, deterministic recent-activity ordering, and privacy-aware location payloads.
- Supports multiple geocoding providers while retaining textual locations when geocoding is not required.

## Pro extension

[Discourse Locations Pro Extension](https://github.com/merefield/discourse-locations-early-access) is an optional private extension available to GitHub Sponsors as a thank-you for supporting ongoing development.

**[Sponsor on GitHub to get Locations Pro](https://github.com/sponsors/merefield)**

Once you have access, install the Pro extension alongside this base plugin to enable:

- Automated user-location estimation from IP data, with configurable precision and privacy safeguards.
- Nearby-topic discovery based on the signed-in user's saved location.
- Optional location-aware tools for `discourse-chatbot`.
- Permission-aware group and result-limit filters on the users map.
- An interactive WebGL globe alternative to the base Leaflet users map.
- An optional idle globe screen saver that reuses the interactive renderer.

The Pro extension has its own master setting and feature settings. Disabling or removing it leaves this base plugin's appearance and functionality unchanged.

## Installation

Add the public plugin to your Discourse container's plugin clone section:

```shell
git clone https://github.com/merefield/discourse-locations.git
```

See [How to install plugins in Discourse](https://meta.discourse.org/t/install-plugins-in-discourse/19157) for the standard installation process.

## Privacy and storage

Complete editable locations are stored in model custom fields. The `locations_user` and `locations_topic` tables contain spatial projections used for map membership, proximity, distance, and ordering.

Raw location custom fields are not globally public. The plugin exposes normalized data only through purpose-specific serializers and applies Discourse profile, group, and directory visibility rules to map results.

See [Location data ownership](docs/location-data-ownership.md) for the storage contract and reconciliation task.

## Extension API

Extension API version 1 is the baseline contract used by the base and Pro pairing. Extensions can verify compatibility with `Locations::EXTENSION_API_VERSION` after the base plugin initializes.

- Server-side extensions should use `Locations::UserLocationStore` and `Locations::TopicLocationStore` instead of reading location custom fields directly.
- Client-side extensions can read the normalized current-user location from `currentUser.geo_location`.
- Users-map extensions can use the `locations-users-map-controls` and `locations-users-map-surface` outlets and the `locations_users_map_query_options` server modifier.

## Documentation and support

- [Administration settings](https://coop.pavilion.tech/docs?topic=1620)
- [Locations in topics](https://coop.pavilion.tech/docs?topic=1763)
- [Locations in categories](https://coop.pavilion.tech/docs?topic=1550)
- [Community discussion](https://meta.discourse.org/t/locations-plugin/69742?u=merefield)
- [Report a bug](https://coop.pavilion.tech/w/bug-report)
