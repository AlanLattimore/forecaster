require "rails_helper"

RSpec.describe CensusGovGeocoder do
  setup do
    address   = Address.new(street: "10 Corse St", city: "Montpelier", state: "Vermont", zip: "05602")
    @geocoder = CensusGovGeocoder.new(address: address)
  end

  it "returns a result set upon successful completion" do
    VCR.use_cassette("census_gov_geocoder_single_address") do
      result_set = @geocoder.query
      expect(result_set.status).to eq 200
      expect(result_set.error).to be_nil
      expect(result_set.address_matches.size).to eq 1
      address_match = result_set.address_matches.first
      expect(address_match.longitude).to eq -72.5749091304874
      expect(address_match.latitude).to eq 44.26380948438649
    end
  end

  it "handles a connection timeout" do
    connection = Faraday::Connection.new
    allow(Faraday).to receive(:new).and_return(connection)
    allow(connection).to receive(:run_request).and_raise(Faraday::TimeoutError)
    result_set = @geocoder.query
    expect(result_set.error).to eq "timeout"
  end

  it "logs requests" do
    VCR.use_cassette("census_gov_geocoder_single_address") do
      orig_logger = Rails.logger.dup
      logger_output = StringIO.new
      begin
        Rails.logger = ActiveSupport::Logger.new(logger_output)
        @geocoder.query
        expect(logger_output.string).to include "CensusGov Geocoder Request"
        expect(logger_output.string).to include "GET https://geocoding.geo.census.gov/geocoder/locations/address?benchmark=Public_AR_Current&city=Montpelier&format=json&state=Vermont&street=10+Corse+St&zip=05602"
      ensure
        Rails.logger = orig_logger
      end
    end
  end
end
