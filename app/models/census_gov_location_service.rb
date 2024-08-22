# frozen_string_literal: true

# A service class to instance a Location object initialized with the content from a successful HTTP request to
#   the Census.gov geolocation service.
class CensusGovLocationService
  # @return [Hash{String => Value}]
  attr_reader :geocoder_data

  def initialize(geocoder_data:)
    @geocoder_data = geocoder_data
  end

  # digs through the Hash to find the location data.
  # @return [Array(Location)] Array of locations pulled fr4om the Census.gov geoloction HTTP reqponse payload
  def locations
    geocoder_data["addressMatches"].map do |address_match|
      Location.new(zip: address_match["addressComponents"]["zip"], longitude: address_match["coordinates"]["x"], latitude: address_match["coordinates"]["y"])
    end
  end
end
