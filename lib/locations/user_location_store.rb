# frozen_string_literal: true

module ::Locations
  class UserLocationStore
    FIELD_NAME = "geo_location"

    def self.fetch(user)
      Payload.parse(user&.custom_fields&.[](FIELD_NAME))
    end

    def self.geocoded?(user)
      Payload.geocoded?(fetch(user))
    end

    def self.set(user:, location:)
      payload = Payload.parse(location)
      if payload.present? && !Payload.geocoded?(payload)
        raise Discourse::InvalidParameters.new,
              I18n.t("location.errors.invalid")
      end

      User.transaction do
        user.custom_fields[FIELD_NAME] = payload&.to_json || ""
        user.save_custom_fields(true)
        sync(user, payload:)
      end

      payload
    end

    def self.sync(user_or_id, payload: nil)
      user = user_or_id.is_a?(User) ? user_or_id : User.find_by(id: user_or_id)
      return delete(user_or_id) if user.blank?
      return :unchanged if payload.nil? && !user.custom_fields.key?(FIELD_NAME)

      payload ||= fetch(user)
      return delete(user.id) if !Payload.geocoded?(payload)

      UserLocation.upsert(
        projection_attributes(user.id, payload),
        on_duplicate: :update,
        unique_by: :user_id
      )
      :upserted
    end

    def self.delete(user_or_id)
      user_id = user_or_id.respond_to?(:id) ? user_or_id.id : user_or_id
      UserLocation.where(user_id:).delete_all
      :deleted
    end

    def self.projection_attributes(user_id, payload)
      {
        user_id:,
        latitude: payload["lat"],
        longitude: payload["lon"],
        street: payload["street"],
        district: payload["district"],
        city: payload["city"],
        state: payload["state"],
        postalcode: payload["postalcode"],
        country: payload["country"],
        countrycode: payload["countrycode"],
        international_code: payload["international_code"],
        locationtype: payload["type"],
        boundingbox: payload["boundingbox"]
      }
    end
    private_class_method :projection_attributes
  end
end
