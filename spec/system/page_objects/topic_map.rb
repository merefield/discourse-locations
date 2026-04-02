# frozen_string_literal: true

module PageObjects
  module Pages
    class TopicMap < PageObjects::Pages::Base
      def visit_general
        page.visit("/latest")
        page.execute_script(
          'window.require("discourse/lib/url").default.routeTo("/map")'
        )
        self
      end

      def visit_category(category)
        page.visit("/c/#{category.slug}/#{category.id}")
        self
      end

      def has_map?
        page.has_css?(".map-component.map-container", wait: 10) &&
          page.has_css?(".locations-map .leaflet-container", wait: 10)
      end

      def has_marker_count?(count)
        page.has_css?(".leaflet-marker-icon", count: count, wait: 10)
      end

      def has_topic_tooltip?(title)
        page.has_css?(".topic-title-map-tooltip", text: title, wait: 10)
      end

      def has_no_topic_tooltip?(title)
        page.has_no_css?(".topic-title-map-tooltip", text: title, wait: 10)
      end
    end
  end
end
