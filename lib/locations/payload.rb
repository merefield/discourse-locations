# frozen_string_literal: true

module ::Locations
  class Payload
    def self.parse(value)
      value = JSON.parse(value) if value.is_a?(String)
      value = value.to_h if value.is_a?(ActionController::Parameters)
      return if !value.is_a?(Hash) || value.empty?

      value.deep_stringify_keys
    rescue JSON::ParserError
      nil
    end

    def self.geocoded?(value)
      payload = parse(value)
      payload.present? && payload["lat"].present? && payload["lon"].present?
    end
  end
end
