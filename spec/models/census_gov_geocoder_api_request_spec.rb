# frozen_string_literal: true

require "rails_helper"

RSpec.describe CensusGovGeocoderApiRequest do
  setup do
    address = Address.new(street: "10 Corse St", city: "Montpelier", state: "Vermont", zip: "05602")
    @geocoder = CensusGovGeocoderApiRequest.new(address: address)
  end

  it "returns data in the expected format" do
    VCR.use_cassette("census_gov_geocoder_single_address") do
      @geocoder.get => { http_status:, error:, data: }
      expect(data["addressMatches"].length).to eq 1
      address_match = data["addressMatches"].first
      expect(address_match["coordinates"]["x"]).to eq -72.5749091304874
      expect(address_match["coordinates"]["y"]).to eq 44.26380948438649
    end
  end

  it "returns HTTP success on successful completion" do
    VCR.use_cassette("census_gov_geocoder_single_address") do
      @geocoder.get => { http_status:, error:, data: }
      expect(http_status).to eq 200
    end
  end

  it "does not set error on successful completion" do
    VCR.use_cassette("census_gov_geocoder_single_address") do
      @geocoder.get => { http_status:, error:, data: }
      expect(error).to be_nil
    end
  end

  it "returns an error on response timeout" do
    connection = Faraday::Connection.new
    allow(Faraday).to receive(:new).and_return(connection)
    allow(connection).to receive(:run_request).and_raise(Faraday::TimeoutError)
    @geocoder.get => { http_status:, error:, data: }
    expect(error).to eq "timeout"
  end

  it "does not set HTTP status on a response timeout" do
    connection = Faraday::Connection.new
    allow(Faraday).to receive(:new).and_return(connection)
    allow(connection).to receive(:run_request).and_raise(Faraday::TimeoutError)
    @geocoder.get => { http_status:, error:, data: }
    expect(http_status).to be_nil
  end

  it "logs requests" do
    VCR.use_cassette("census_gov_geocoder_single_address") do
      orig_logger = Rails.logger.dup
      logger_output = StringIO.new
      begin
        Rails.logger = ActiveSupport::Logger.new(logger_output)
        @geocoder.get
        expect(logger_output.string).to include "CensusGov Geocoder Request"
        expect(logger_output.string).to include "GET https://geocoding.geo.census.gov/geocoder/locations/address?benchmark=Public_AR_Current&city=Montpelier&format=json&state=Vermont&street=10+Corse+St&zip=05602"
      ensure
        Rails.logger = orig_logger
      end
    end
  end
end
