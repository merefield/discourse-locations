# frozen_string_literal: true

module ::Locations
  class TopicLocationStore
    FIELD_NAME = "location"
    GEO_FIELD_NAME = "has_geo_location"

    def self.fetch(topic)
      Payload.parse(topic&.custom_fields&.[](FIELD_NAME))
    end

    def self.assign(topic:, location:)
      payload = Payload.parse(location)
      topic.custom_fields[FIELD_NAME] = payload || {}
      topic.custom_fields[GEO_FIELD_NAME] = geocoded?(payload)
      sync(topic, payload:)
      payload
    end

    def self.geocoded?(payload)
      Payload.geocoded?(payload&.[]("geo_location"))
    end

    def self.sync(topic_or_id, payload: nil)
      topic =
        topic_or_id.is_a?(Topic) ? topic_or_id : Topic.find_by(id: topic_or_id)
      return delete(topic_or_id) if topic.blank?

      payload ||= fetch(topic)
      return delete(topic.id) if !geocoded?(payload)

      TopicLocation.upsert(
        projection_attributes(topic.id, payload),
        on_duplicate: :update,
        unique_by: :topic_id
      )
      :upserted
    end

    def self.delete(topic_or_id)
      topic_id = topic_or_id.respond_to?(:id) ? topic_or_id.id : topic_or_id
      TopicLocation.where(topic_id:).delete_all
      :deleted
    end

    def self.projection_attributes(topic_id, payload)
      geo_location = payload.fetch("geo_location")

      {
        topic_id:,
        latitude: geo_location["lat"],
        longitude: geo_location["lon"],
        name: value(payload, geo_location, "name"),
        street: value(payload, geo_location, "street"),
        district: value(payload, geo_location, "district"),
        city: value(payload, geo_location, "city"),
        state: value(payload, geo_location, "state"),
        postalcode: value(payload, geo_location, "postalcode"),
        country: value(payload, geo_location, "country"),
        countrycode: value(payload, geo_location, "countrycode"),
        international_code: value(payload, geo_location, "international_code"),
        locationtype: value(payload, geo_location, "type"),
        boundingbox: value(payload, geo_location, "boundingbox")
      }
    end

    def self.value(payload, geo_location, key)
      payload[key].presence || geo_location[key]
    end
    private_class_method :projection_attributes, :value
  end
end
