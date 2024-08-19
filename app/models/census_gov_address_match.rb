# frozen_string_literal: true

class CensusGovAddressMatch
  attr_reader :address_match

  def initialize(address_match:)
    @address_match = address_match
  end

  def zip
    address_match["addressComponents"]["zip"]
  end

  def x
    address_match["coordinates"]["x"]
  end
  alias_method :longitude, :x

  def y
    address_match["coordinates"]["y"]
  end
  alias_method :latitude, :y
end
