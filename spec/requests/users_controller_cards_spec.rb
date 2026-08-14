# frozen_string_literal: true

RSpec.describe UsersController do
  fab!(:user)
  fab!(:user_without_location, :user)

  describe "#cards" do
    it "returns bespoke locations without exposing their canonical custom fields" do
      SiteSetting.location_enabled = true
      SiteSetting.public_user_custom_fields = "department"
      user.user_stat.update!(post_count: 1)
      user_without_location.user_stat.update!(post_count: 1)
      location = {
        lat: 51.5074,
        lon: -0.1278,
        city: "London",
        countrycode: "gb"
      }
      Locations::UserLocationStore.set(user:, location:)
      user.custom_fields["department"] = "Engineering"
      user.save_custom_fields

      get "/user-cards.json",
          params: {
            user_ids: "#{user.id},#{user_without_location.id}"
          }

      expect(response).to have_http_status(:ok)
      cards =
        response
          .parsed_body
          .fetch("users")
          .index_by { |card| card.fetch("username") }
      expect(cards.fetch(user.username).fetch("geo_location")).to eq(
        location.stringify_keys
      )
      expect(cards.fetch(user_without_location.username)).not_to have_key(
        "geo_location"
      )
      expect(cards.fetch(user.username).fetch("custom_fields")).to eq(
        "department" => "Engineering"
      )
    end
  end
end
