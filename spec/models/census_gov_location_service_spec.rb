# frozen_string_literal: true

require "rails_helper"

RSpec.describe CensusGovLocationService do
  before do
    data = {
      "input" => {
        "address" => {
          "city" => "Montpelier",
          "street" => "10 Corse Street",
          "state" => "VT"
        },
        "benchmark" => {
          "isDefault" => true,
          "benchmarkDescription" => "Public Address Ranges - Current Benchmark",
          "id" => "4",
          "benchmarkName" => "Public_AR_Current"
        }
      },
      "addressMatches" => [
        {
          "tigerLine" => {
            "side" => "L",
            "tigerLineId" => "136666375"
          },
          "coordinates" => {
            "x" => -72.5749091304874,
            "y" => 44.26380948438649
          },
          "addressComponents" => {
            "zip" => "05602",
            "streetName" => "CORSE",
            "preType" => "",
            "city" => "MONTPELIER",
            "preDirection" => "",
            "suffixDirection" => "",
            "fromAddress" => "2",
            "state" => "VT",
            "suffixType" => "ST",
            "toAddress" => "18",
            "suffixQualifier" => "",
            "preQualifier" => ""
          },
          "matchedAddress" => "10 CORSE ST, MONTPELIER, VT, 05602"
        }
      ]
    }
    @service = CensusGovLocationService.new(geocoder_data: data)
  end

  it "returns a list" do
    expect(@service.locations).to be_a(Array)
  end

  it "is a list of Locations" do
    expect(@service.locations.size).to eq(1)
    expect(@service.locations.first).to be_a Location
  end

  it "sets zip" do
    location = @service.locations.first
    expect(location.zip).to eq "05602"
  end

  it "sets longitude" do
    location = @service.locations.first
    expect(location.longitude).to eq -72.5749091304874
  end

  it "sets latitude" do
    location = @service.locations.first
    expect(location.latitude).to eq 44.26380948438649
  end
end
