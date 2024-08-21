class ForecastController < ApplicationController
  def new
    @address = Address.new
  end

  def create
    @address = Address.new(address_params)

    unless @address.valid?
      flash.now.notice = @address.errors.full_messages
      render :forecast
      return
    end

    geocoder = CensusGovGeocoderApiRequest.new(address: @address)
    geocoder.get => { http_status:, error:, data: }

    if http_status != 200
      flash.now.alert = "Something happened when Punxsutawney Phil -- our chief forecaster -- tripped over #{ http_status }: #{ error } while trying to help you. He thinks you should try again."
      render :forecast
      return
    end

    if error.present?
      flash.now.alert = "It looks like our chief forecaster -- Punxsutawney Phil -- wasn't quite fast enough and his search for your location timed out. He says to try again."
      render :forecast
      return
    end

    locations = CensusGovLocationService.new(geocoder_data: data).locations

    unless locations.one?
      flash.now.alert = "Punxsutawney Phil -- our chief forecaster -- was unable to find an exact match for your address. Help him locate your home on his weather map by double checking the address."
      render :forecast
      return
    end

    location = locations.first
    @address.zip = location.zip if @address.zip.blank?
    @address.assign_attributes(latitude: location.latitude, longitude: location.longitude)

    meteorological_data = OpenMeteoMeteorologicalApiRequest.new(longitude: @address.longitude, latitude: @address.latitude)
    meteorological_data.get => { http_status:, error:, data: }

    if http_status != 200
      flash.now.alert = "Something happened when Punxsutawney Phil -- our chief forecaster -- tripped over #{ http_status }: #{ error } while trying to help you. He thinks you should try again."
      render :forecast
      return
    end

    if error.present?
      flash.now.alert = "It looks like our chief forecaster -- Punxsutawney Phil -- wasn't quite fast enough and his search for your location timed out. He says to try again."
      render :forecast
      return
    end

    @forecast = OpenMeteoForecastService.new(meteorological_data: data).forecast
    render :forecast
  end

private

  def address_params
    params.require(:address).permit(:street, :urb, :city, :state, :municipio, :zip)
  end
end
