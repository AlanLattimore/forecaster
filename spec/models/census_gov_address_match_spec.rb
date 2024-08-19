# frozen_string_literal: true

require "rails_helper"

RSpec.describe CensusGovAddressMatch do
  setup do
    @address_match = CensusGovAddressMatch.new(address_match:
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
    )
  end

  it "presents the correct zipcode" do
    expect(@address_match.zip).to eq "05602"
  end

  it "presents the longitude" do
    expect(@address_match.longitude).to eq -72.5749091304874
  end

  it "presents the latitude" do
    expect(@address_match.latitude).to eq 44.26380948438649
  end
end
