# frozen_string_literal: true

RSpec.describe CurrentUserSerializer do
  fab!(:user)

  let(:serialized_user) do
    described_class.new(user, scope: user.guardian, root: false).as_json
  end

  before { SiteSetting.location_enabled = true }

  it "includes the current user's normalized location" do
    location = { lat: 51.5074, lon: -0.1278, city: "London" }
    user.custom_fields["geo_location"] = location.to_json
    user.save_custom_fields

    expect(serialized_user[:geo_location]).to eq(location.stringify_keys)
  end

  it "returns no current-user location when none is saved" do
    expect(serialized_user[:geo_location]).to be_nil
  end

  it "returns no current-user location when the stored value is invalid" do
    user.custom_fields["geo_location"] = "not-json"
    user.save_custom_fields

    expect(serialized_user[:geo_location]).to be_nil
  end
end
