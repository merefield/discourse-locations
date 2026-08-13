# frozen_string_literal: true

RSpec.describe PostSerializer do
  fab!(:post)

  let(:location) do
    {
      "lat" => 51.5074,
      "lon" => -0.1278,
      "city" => "London",
      "countrycode" => "gb"
    }
  end
  let(:serialized_post) do
    described_class.new(post, scope: post.user.guardian, root: false).as_json
  end

  before do
    SiteSetting.location_enabled = true
    SiteSetting.public_user_custom_fields = "department"
    Locations::UserLocationStore.set(user: post.user, location:)
  end

  it "exposes the bespoke post location only when post locations are enabled" do
    SiteSetting.location_user_post = true

    expect(serialized_post[:user_geo_location]).to eq(location)
    expect(serialized_post.fetch(:user_custom_fields, {})).not_to include(
      "geo_location",
      :geo_location
    )
  end

  it "does not expose a post location when post locations are disabled" do
    SiteSetting.location_user_post = false

    expect(serialized_post).not_to have_key(:user_geo_location)
    expect(serialized_post.fetch(:user_custom_fields, {})).not_to include(
      "geo_location",
      :geo_location
    )
  end
end
