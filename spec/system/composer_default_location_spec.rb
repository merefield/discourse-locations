# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Composer default location", type: :system do
  fab!(:user) { Fabricate(:user, refresh_auto_groups: true) }
  fab!(:category) do
    Fabricate(:category_with_definition, custom_fields: { location_enabled: true })
  end
  let(:category_page) { PageObjects::Pages::Category.new }

  let(:geo_location) do
    {
      lat: "51.5073219",
      lon: "-0.1276474",
      address: "London, Greater London, England, United Kingdom",
      countrycode: "gb",
      city: "London",
      state: "England",
      country: "United Kingdom",
      postalcode: "",
      boundingbox: %w[51.2867601 51.6918741 -0.5103751 0.3340155],
      type: "city",
    }
  end

  before do
    SiteSetting.location_enabled = true
    SiteSetting.location_topic_default = "user"
    SiteSetting.default_composer_category = category.id
    SiteSetting.create_topic_allowed_groups =
      "#{Group::AUTO_GROUPS[:admins]}|#{Group::AUTO_GROUPS[:moderators]}|#{Group::AUTO_GROUPS[:trust_level_0]}"

    category.set_permissions(everyone: :full)
    category.save!

    user.custom_fields["geo_location"] = geo_location.to_json
    user.save_custom_fields(true)

    sign_in(user)
  end

  it "initialises the composer location from the user location" do
    category_page.visit(category)
    category_page.new_topic_button.click

    expect(page).to have_css("#reply-control.open")
    select_kit = PageObjects::Components::SelectKit.new("#reply-control.open .category-chooser")
    expect(select_kit).to have_selected_value(category.id)

    expect(page).to have_css(
      "#reply-control.open .location-label .d-button-label",
      text: geo_location[:address],
      wait: 10,
    )
  end
end
