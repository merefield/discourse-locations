# frozen_string_literal: true
require "rails_helper"

describe ::Locations::GeoLocationBuilder do
  it "builds geo_location from chosen feature and granularity" do
    allow(::Locations::GeoNamesGranularityPicker).to receive(:pick).and_return(
      {
        geoname_id: 42,
        name: "Andalusia",
        lat: 36.7,
        lon: -4.4,
        fcl: "A",
        fcode: "ADM1",
        country_code: "ES",
        country_name: "Spain",
        admin1: "Andalusia",
      },
    )

    ip_info = { geoname_ids: [42], country: "Spain", country_code: "ES" }
    result = described_class.from_ip_info(ip_info, granularity: "province")

    expect(result["lat"]).to eq(36.7)
    expect(result["lon"]).to eq(-4.4)
    expect(result["state"]).to eq("Andalusia")
    expect(result["city"]).to be_nil
    expect(result["country"]).to eq("Spain")
    expect(result["countrycode"]).to eq("es")
    expect(result["geoAttrs"]["geoname_id"]).to eq(42)
  end

  it "uses county name in state for county granularity" do
    allow(::Locations::GeoNamesGranularityPicker).to receive(:pick).and_return(
      {
        geoname_id: 99,
        name: "Los Angeles County",
        lat: 34.05,
        lon: -118.25,
        fcl: "A",
        fcode: "ADM2",
        country_code: "US",
        country_name: "United States",
        admin1: "California",
      },
    )

    ip_info = { geoname_ids: [99], country: "United States", country_code: "US" }
    result = described_class.from_ip_info(ip_info, granularity: "county")

    expect(result["state"]).to eq("Los Angeles County")
    expect(result["city"]).to be_nil
    expect(result["country"]).to eq("United States")
  end
end
