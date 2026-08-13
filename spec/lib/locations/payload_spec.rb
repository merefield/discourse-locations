# frozen_string_literal: true

RSpec.describe Locations::Payload do
  describe ".parse" do
    it "normalizes unpermitted controller parameters" do
      params = ActionController::Parameters.new(lat: "51.5074", lon: "-0.1278")

      expect(described_class.parse(params)).to eq(
        "lat" => "51.5074",
        "lon" => "-0.1278"
      )
    end
  end
end
