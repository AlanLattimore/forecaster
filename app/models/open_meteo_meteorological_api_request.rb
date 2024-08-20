# frozen_string_literal: true

require "addressable/template"

class OpenMeteoMeteorologicalApiRequest
  attr_reader :error, :longitude, :latitude, :raw, :http_status

  def initialize(longitude:, latitude:)
    @longitude = longitude
    @latitude = latitude
  end

  def get
    connection = Faraday.new(url: uri.to_s) do |builder|
      # Sets the Content-Type header to application/json on each request.
      builder.request :json

      # Parses JSON response bodies.
      # If the response body is not valid JSON, it will raise a Faraday::ParsingError.
      builder.response :json

      # Logs requests and responses.
      # `detailed_logger` gives a one line log message which is more useful
      # Tag output with `CensusGov Geocoder Request` to make finding relevant messages easier.
      builder.response :detailed_logger, Rails.logger, "OpenMateo Meteorological Data Request"
    end

    begin
      @raw = connection.get
      http_status = @raw.status
    rescue Faraday::TimeoutError => e
      error = e.message
    rescue Faraday::Error => e
      http_status = e.response[:status]
      error = e.response[:error]
    end

    { http_status:, error:, data: @raw&.body }
  end

  def uri
    uri = Addressable::URI.parse("https://api.open-meteo.com/v1/forecast")
    uri.query = Rack::Utils.build_query(
      {
        "longitude" => longitude,
        "latitude" => latitude,
        "temperature_unit" => "fahrenheit",
        "current" => "temperature_2m",
        "daily" => "temperature_2m_max,temperature_2m_min",
        "forecast_days" => 7
      }
    )
    uri
  end
end
