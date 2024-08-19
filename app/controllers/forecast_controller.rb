class ForecastController < ApplicationController
  def new
    @address = Address.new
  end

  def create
    @address = Address.new(address_params)

    if @address.valid?
      geocoder = CensusGovGeocoder.new(address: @address)
      result_set = geocoder.query
      case
      when result_set.status != 200
        render :flash, alert: "Something happened when Punxsutawney Phil -- our chief forecaster -- tripped over #{ result_set.status }: #{ result_set.error } while trying to help you. He thinks you should try again."
      when !result_set.address_matches.one?
        render :flash, alert: "Punxsutawney Phil -- our chief forecaster -- was unable to find an exact match for your address. Help him locate your home on his weather map by double checking the address."
      else
        address_match = result_set.address_matches.first
        @address.zip = address_match.zip if @address.zip.blank?
        @address.assign_attributes(latitude: address_match.latitude, longitude: address_match.longitude)
      end
    else
      render :flash, notice: @address.errors.full_messages
    end
  end

  private

  def address_params
    params.require(:address).permit(:street, :urb, :city, :state, :municipio, :zip)
  end
end
