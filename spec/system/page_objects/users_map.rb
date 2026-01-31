# frozen_string_literal: true

module PageObjects
  module Pages
    class UsersMap < PageObjects::Pages::Base
      def visit
        page.visit("/locations/users_map")
      end

      def has_marker_count?(count)
        expect(page).to have_css(".leaflet-marker-icon", count: count, wait: 10)
      end
    end
  end
end
