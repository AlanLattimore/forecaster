class ForecastController < ApplicationController
  def new
    @address = Address.new
  end

  def create
    @address = Address.new(address_params)
    render :validation_errors unless @address.valid?
  end

  private

  def address_params
    params.require(:address).permit(:street, :urb, :city, :state, :municipio, :zip)
  end
end
