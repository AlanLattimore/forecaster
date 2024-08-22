# frozen_string_literal: true

require "addressable/template"

# A class to encapsulate logiv for sending an HTTP request to the Census.gov geocoding service and processing the
#   response
class CensusGovGeocoderApiRequest
  # @return [String,nil] error message for an HTTP result other than success. 'Timeout' for a timeout error
  attr_reader :error

  # @return [Address] The address to be geolocated
  attr_reader :address

  # 2return [Faraday::Response] the original Faraday response including headers; for diagnostic purposes
  attr_reader :raw

  # @return [Integer, nil] HTTP status. 200 for success. Nil for an error other than an HTTP error.
  attr_reader :http_status

  def initialize(address:)
    @address = address
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
      builder.response :detailed_logger, Rails.logger, "CensusGov Geocoder Request"
    end

    begin
      @raw   = connection.get
      @http_status = @raw.status
    rescue Faraday::TimeoutError => e
      @error = e.message
    rescue Faraday::Error => e
      @http_status = e.response[:status]
      @error  = e.response[:error]
    end
    { http_status:, error:, data: @raw&.body&.dig("result") }
  end

  # Utility method to determine the URL for the GEt request endpoint
  # @return [Addressable::URI] URI endpoint for HTTP request.
  def uri
    template  = Addressable::Template.new("https://geocoding.geo.census.gov/geocoder/locations/{search_type}")
    uri       = template.expand(search_type: search_type)
    uri.query = Rack::Utils.build_query(
      {
        "benchmark" => "Public_AR_Current",
        "format"    => "json"
      }.merge(address.attributes).compact
    )
    uri
  end

  # Utility method to calculate the HTTP requesst endpoint based on whether an address is urbanized or not.
  # @ return [String] search type to conduct
  def search_type
    @address.urbanized? ? "addressPR" : "address"
  end
end
