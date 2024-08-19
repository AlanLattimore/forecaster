# frozen_string_literal: true

require "addressable/template"

class CensusGovGeocoder
  attr_reader :address, :raw

  def initialize(address:)
    @address = address
  end

  def query
    result_set = CensusGovResultSet.new
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
      @raw                       = connection.get
      result_set.status          = @raw.status
      result_set.address_matches = @raw.body["result"]["addressMatches"].map do |address_match|
        CensusGovAddressMatch.new(address_match: address_match)
      end
    rescue Faraday::TimeoutError => e
      result_set.error = e.message
    rescue Faraday::Error => e
      result_set.status = e.response[:status]
      result_set.error  = e.response[:error]
    end
    result_set
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
