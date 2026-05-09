# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Category location settings" do
  fab!(:admin)
  fab!(:category, :category_with_definition)

  let(:category_page) { PageObjects::Pages::Category.new }

  def toggle_location_setting(label)
    find(".form-kit__field", text: label).find(".form-kit__control-checkbox").click
  end

  def expect_location_custom_fields(enabled)
    category.reload

    expect(category.custom_fields["location_enabled"]).to eq(enabled)
    expect(category.custom_fields["location_topic_status"]).to eq(enabled)
    expect(category.custom_fields["location_map_filter_closed"]).to eq(enabled)
  end

  before do
    SiteSetting.location_enabled = true
    SiteSetting.enable_simplified_category_creation = true

    sign_in(admin)
  end

  it "saves location custom fields from the simplified category settings form" do
    category_page.visit_settings(category)

    toggle_location_setting(I18n.t("js.category.location_enabled"))
    toggle_location_setting(I18n.t("js.category.location_topic_status"))
    toggle_location_setting(I18n.t("js.category.location_map_filter_closed"))
    category_page.save_settings

    expect_location_custom_fields(true)

    category_page.visit_settings(category)

    toggle_location_setting(I18n.t("js.category.location_enabled"))
    toggle_location_setting(I18n.t("js.category.location_topic_status"))
    toggle_location_setting(I18n.t("js.category.location_map_filter_closed"))
    category_page.save_settings

    expect_location_custom_fields(false)
  end
end
