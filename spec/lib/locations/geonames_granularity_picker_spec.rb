# frozen_string_literal: true
require "rails_helper"

describe ::Locations::GeoNamesGranularityPicker do
  def build_feature(attrs = {})
    {
      geoname_id: 1,
      name: "X",
      lat: 1.0,
      lon: 2.0,
      fcl: "A",
      fcode: "PCLI",
      country_code: "US",
      country_name: "United States",
      admin1: "CA",
    }.merge(attrs)
  end

  before do
    allow_any_instance_of(::Locations::GeoNamesClient).to receive(:get_feature) do |_, id|
      case id
      when 10
        build_feature(geoname_id: 10, fcl: "A", fcode: "PCLI", name: "United States")
      when 11
        build_feature(geoname_id: 11, fcl: "A", fcode: "ADM1", name: "California")
      when 12
        build_feature(geoname_id: 12, fcl: "P", fcode: "PPLA", name: "Sacramento")
      when 13
        build_feature(geoname_id: 13, fcl: "P", fcode: "PPL", name: "Fresno")
      end
    end
  end

  it "picks country for country granularity" do
    chosen = described_class.pick([10, 11, 12], granularity: "country")
    expect(chosen[:geoname_id]).to eq(10)
  end

  it "picks admin1 for province granularity" do
    chosen = described_class.pick([10, 11, 12], granularity: "province")
    expect(chosen[:geoname_id]).to eq(11)
  end

  it "picks best city for city granularity" do
    chosen = described_class.pick([10, 11, 12, 13], granularity: "city")
    expect(chosen[:geoname_id]).to eq(12)
  end
end
