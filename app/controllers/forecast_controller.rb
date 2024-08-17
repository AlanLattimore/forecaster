class ForecastController < ApplicationController
  def new
    @address = Address.new
  end

  def create
    @address = Address.new(address_params)
    case
    when !@address.valid?
      render :new
    end
  end

  private

  def address_params
    params.require(:address).permit(:street, :urb, :city, :state, :municipio, :zip)
  end
end
