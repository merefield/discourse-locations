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

Client-side extensions can normalize the serialized user location with the shared parser instead of duplicating its rules:

```js
import { parseGeoLocation } from "discourse/plugins/discourse-locations/discourse/lib/location-utilities";
```
