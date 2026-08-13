# Discourse Locations Plugin

The Locations Plugin allows you to associate geocoded locations with topics, and list topics with locations on a map. Additionally it allows users to record their position (voluntarily) and this can show up on a map of Users in the Users directory.

:page_facing_up: [**Read the documentation**](https://coop.pavilion.tech/docs?category=90&solved=false)

:bug: **[Report a bug](https://coop.pavilion.tech/w/bug-report)**

### Documentation Links

- [Administration Settings](https://coop.pavilion.tech/docs?topic=1620)
- [Locations in Topics](https://coop.pavilion.tech/docs?topic=1763)
- [Locations in Categories](https://coop.pavilion.tech/docs?topic=1550)

### Extension API

Version 7.3.7 introduces extension API version 1. Extensions can verify compatibility with `Locations::EXTENSION_API_VERSION` after the base plugin initializes.

Client-side extensions can read the normalized current-user location from `currentUser.geo_location`. The value is a location object when the current user has a valid saved location, otherwise it is `null`. Storage format and parsing remain internal to the base plugin.

Server-side extensions should use `Locations::UserLocationStore` and `Locations::TopicLocationStore` rather than reading location custom fields directly. See [Location data ownership](docs/location-data-ownership.md) for the API and projection invariants.
