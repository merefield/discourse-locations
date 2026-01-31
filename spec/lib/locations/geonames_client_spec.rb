# frozen_string_literal: true
require "rails_helper"

describe ::Locations::GeoNamesClient do
  let(:client) { described_class.new }

  before { SiteSetting.location_geonames_username = "tester" }

  it "normalizes a GeoNames response" do
    body = {
      "geonameId" => 6_295_630,
      "name" => "Earth",
      "lat" => "0",
      "lng" => "0",
      "fcl" => "L",
      "fcode" => "AREA",
      "countryCode" => "",
      "countryName" => "",
      "adminName1" => "",
    }.to_json

    allow(FinalDestination::HTTP).to receive(:get).and_return(body)

    feature = client.get_feature(6_295_630)

    expect(feature[:geoname_id]).to eq(6_295_630)
    expect(feature[:name]).to eq("Earth")
    expect(feature[:lat]).to eq(0.0)
    expect(feature[:lon]).to eq(0.0)
    expect(feature[:fcl]).to eq("L")
    expect(feature[:fcode]).to eq("AREA")
  end

  it "returns nil when username is missing" do
    SiteSetting.location_geonames_username = ""
    expect(client.get_feature(6_295_630)).to be_nil
  end
end
