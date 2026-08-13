# frozen_string_literal: true

module ::Locations
  class Helper
    def self.parse_location(location)
      Payload.parse(location)
    end
  end
end
