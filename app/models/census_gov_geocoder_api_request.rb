# frozen_string_literal: true

require "addressable/template"

class CensusGovGeocoderApiRequest
  attr_reader :error, :address, :raw, :http_status

  def initialize(address:)
    @address = address
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
      builder.response :detailed_logger, Rails.logger, "CensusGov Geocoder Request"
    end

    begin
      @raw   = connection.get
      http_status = @raw.status
    rescue Faraday::TimeoutError => e
      error = e.message
    rescue Faraday::Error => e
      http_status = e.response[:status]
      error  = e.response[:error]
    end
    { http_status:, error:, data: @raw&.body&.dig("result") }
  end

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

  def search_type
    @address.urbanized? ? "addressPR" : "address"
  end
end
