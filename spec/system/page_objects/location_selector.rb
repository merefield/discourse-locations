# frozen_string_literal: true

module PageObjects
  module Components
    class LocationSelector < PageObjects::Components::Base
      def initialize(context)
        @context = context
      end

      def hidden?
        find("#{@context}").has_no_css?(".location-selector")
      end

      def has_selected_location_with_string?(string)
        selected_locations =
          find("#{@context} .location-selector")
            .all(".d-multi-select-trigger__selected-item")
            .map { |item| item[:innerText] }
        expect(selected_locations).to include(string)
      end

      def has_no_selected_locations?
        find("#{@context} .location-selector").has_no_css?(".d-multi-select-trigger__selected-item")
      end

      def open
        find(@context).find(".location-selector .d-multi-select-trigger__expand-btn").click
        expect(page).to have_css(".fk-d-menu.d-multi-select-content")
      end

      def add_location(location_name)
        self.open
        find(".dropdown-menu__item.d-multi-select__search-container").fill_in(with: location_name)
        find(".dropdown-menu__item.d-multi-select__result[title='#{location_name}']").click
      end

      def remove_location(location_name)
        find(@context)
          .find(".location-selector .d-multi-select-trigger__selected-item", text: location_name)
          .find(".d-multi-select-trigger__remove-selection-icon")
          .click
      end
    end
  end
end
