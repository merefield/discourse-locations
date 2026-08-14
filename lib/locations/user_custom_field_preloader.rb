# frozen_string_literal: true

module ::Locations
  module UserCustomFieldPreloader
    def preload_custom_fields(objects, fields)
      fields = fields.to_a
      fields |= [UserLocationStore::FIELD_NAME] if SiteSetting.location_enabled

      super(objects, fields)
    end
  end
end
