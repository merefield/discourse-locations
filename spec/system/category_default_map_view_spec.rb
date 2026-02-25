# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Category default map view", type: :system do
  fab!(:admin)
  fab!(:category, :category_with_definition)

  let(:category_page) { PageObjects::Pages::Category.new }
  let(:default_view_select_kit) { PageObjects::Components::SelectKit.new("#category-default-view") }

  before do
    SiteSetting.location_enabled = true
    SiteSetting.location_category_map_filter = true

    category.set_permissions(everyone: :full)
    category.custom_fields["location_enabled"] = true
    category.save!

    sign_in(admin)
  end

  it "shows the map view without a route error when map is the category default view" do
    category_page.visit_settings(category)
    default_view_select_kit.expand
    default_view_select_kit.select_row_by_value("map")
    category_page.save_settings

    expect(category.reload.default_view).to eq("map")

    category_page.visit(category)

    expect(page).to have_no_css(".oops-title")
    expect(page).to have_css(".map-component.map-container", wait: 10)
    expect(page).to have_css(".locations-map .leaflet-container", wait: 10)
  end
end
