# Location data ownership

Discourse Locations stores each complete editable location as a model custom field containing a JSON object. The `locations_user` and `locations_topic` tables are spatial projections used for map membership, proximity, distance, and ordering.

User payloads are flat because the whole user location is geocoded. Topic payloads retain their existing `geo_location` nesting because a topic can also carry presentation fields or a textual-only location. This shape difference is intentional.

Topic locations use Discourse's `:json` custom-field metadata. User locations deliberately remain string-typed because the editable-user custom-field pipeline supplies serialized JSON; applying the core JSON descriptor as well would double-encode it. `UserLocationStore` guarantees a single JSON object in the row and returns the same normalized object contract as `TopicLocationStore`.

## Invariants

- Base-plugin stores are the only server APIs that extensions should use to read or write canonical locations.
- A projection row exists only when its canonical location has valid latitude and longitude.
- Clearing or invalidating canonical coordinates removes the corresponding projection row.
- Projection existence is the source of truth for whether a location is geocoded; no duplicate boolean custom field is maintained.
- Public API payloads are emitted by surface-specific serializers; raw location custom fields are not globally public.
- User-map payloads contain only the projected coordinates required to render markers.

## Extension API

Use `Locations::UserLocationStore.fetch(user)` and `Locations::TopicLocationStore.fetch(topic)` to read canonical payloads. Use `Locations::UserLocationStore.set(user:, location:)` when an extension needs to replace a user's location. Spatial queries can use `Locations::UserLocation` and `Locations::TopicLocation` after checking the base extension API version.

Client-side extensions receive the normalized current-user payload as `currentUser.geo_location` and do not need to know how it is stored.

## Reconciliation

Normal writes synchronize projections immediately. Administrators can repair historical or out-of-band drift across all sites with:

```shell
bin/rake locations:reconcile_location_tables
```

The task creates missing projections, refreshes changed projections, and removes projections whose canonical location or owner no longer exists.
