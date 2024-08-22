# frozen_string_literal: true

require "addressable/template"

class OpenMeteoMeteorologicalApiRequest
  # @return [String,nil] error message for an HTTP result other than success. 'Timeout' for a timeout error
  attr_reader :error

  # @return [Float] The longitude for the meteorological data
  attr_reader :longitude

  # @return [Float] The latitude for the meteorological data
  attr_reader :latitude

  # @return [Faraday::Response] the original Faraday response including headers; for diagnostic purposes
  attr_reader :raw

  # @return [Integer, nil] HTTP status. 200 for success. Nil for an error other than an HTTP error.
  attr_reader :http_status

  def initialize(longitude:, latitude:)
    @longitude = longitude
    @latitude = latitude
  end

  # Execute the HTTP request and return the body of the response.
  # @return [Hash{Symbol=>Value}] tuple representing the result of the request.
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
      @http_status = @raw.status
    rescue Faraday::TimeoutError => e
      @error = e.message
    rescue Faraday::Error => e
      @http_status = e.response[:status]
      @error = e.response[:error]
    end

    { http_status:, error:, data: @raw&.body }
  end

  # Utility method to determine the URL for the GEt request endpoint
  # @return [Addressable::URI] URI endpoint for HTTP request.
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
