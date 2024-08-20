class ForecastController < ApplicationController
  def new
    @address = Address.new
  end

  def create
    @address = Address.new(address_params)

    render :flash, notice: @address.errors.full_messages unless @address.valid?

    geocoder = CensusGovGeocoderApiRequest.new(address: @address)
    geocoder.get => { http_status:, error:, data: }
    render :flash, alert: "Something happened when Punxsutawney Phil -- our chief forecaster -- tripped over #{ http_status }: #{ error } while trying to help you. He thinks you should try again." unless http_status == 200
    render :flash, alert: "It looks like our chief forecaster -- Punxsutawney Phil -- wasn't quite fast enough and his seach for your location timed out. He says to try again." unless error.blank?

    locations = CensusGovLocationService.new(geocoder_data: data).locations
    render :flash, alert: "Punxsutawney Phil -- our chief forecaster -- was unable to find an exact match for your address. Help him locate your home on his weather map by double checking the address." unless locations.one?
    location = locations.first
    @address.zip = location.zip if @address.zip.blank?
    @address.assign_attributes(latitude: location.latitude, longitude: location.longitude)

    meteorological_data = OpenMeteoMeteorologicalApiRequest.new(longitude: @address.longitude, latitude: @address.latitude)
    meteorological_data.get => { http_status:, error:, data: }
    render :flash, alert: "Something happened when Punxsutawney Phil -- our chief forecaster -- tripped over #{ http_status }: #{ error } while trying to help you. He thinks you should try again." unless http_status == 200
    render :flash, alert: "It looks like our chief forecaster -- Punxsutawney Phil -- wasn't quite fast enough and he ran out of time while looking up meteorological data for where you live. He says to try again." unless error.blank?

    @forecast = OpenMeteoForecastService.new(meteorological_data: data).forecast
  end

private

  def address_params
    params.require(:address).permit(:street, :urb, :city, :state, :municipio, :zip)
  end
end
