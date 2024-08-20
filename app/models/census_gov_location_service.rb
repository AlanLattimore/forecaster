# frozen_string_literal: true

class CensusGovLocationService
  attr_reader :geocoder_data
  def initialize(geocoder_data:)
    @geocoder_data = geocoder_data
  end

  def locations
    geocoder_data["addressMatches"].map do |address_match|
      Location.new(zip: address_match["addressComponents"]["zip"], longitude: address_match["coordinates"]["x"], latitude: address_match["coordinates"]["y"])
    end
  end
end
