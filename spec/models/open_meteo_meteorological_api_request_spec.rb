# frozen_string_literal: true

require "rails_helper"

RSpec.describe OpenMeteoMeteorologicalApiRequest do
  before do
    @meteorological_data_service = OpenMeteoMeteorologicalApiRequest.new(longitude: -72.5749091304874, latitude: 44.26380948438649)
  end

  it "returns HTTP status 200 for success" do
    VCR.use_cassette("open_meteo_meteorological_data_for_montpelier_vermont") do
      @meteorological_data_service.get => { http_status:, error:, data: }
      expect(http_status).to eq 200
    end
  end

  it "returns no error for success" do
    VCR.use_cassette("open_meteo_meteorological_data_for_montpelier_vermont") do
      @meteorological_data_service.get => { http_status:, error:, data: }
      expect(error).to be_blank
    end
  end

  it "returns data in the expected format" do
    VCR.use_cassette("open_meteo_meteorological_data_for_montpelier_vermont") do
      @meteorological_data_service.get => { http_status:, error:, data: }

      expect(data["longitude"]).to eq -72.57745
      expect(data["latitude"]).to eq 44.274887
      expect(data["current_units"]["temperature_2m"]).to eq "°F"
      expect(data["current"]["temperature_2m"]).to be_present
      expect(data["daily_units"]["temperature_2m_max"]).to eq "°F"
      expect(data["daily_units"]["temperature_2m_min"]).to eq "°F"
      expect(data["daily"]["time"].size).to eq 7
      expect(data["daily"]["temperature_2m_max"].size).to eq 7
      expect(data["daily"]["temperature_2m_min"].size).to eq 7

      # These next 3 expectations are based on data that is point in time and will need to be updated when the cassette
      # changes. They are included here to declare expectations about the API contract
      expect(data["daily"]["time"].first).to eq "2024-08-20"
      expect(data["daily"]["temperature_2m_max"].first).to eq 60.5
      expect(data["daily"]["temperature_2m_min"].first).to eq 53.0
    end
  end

  it "returns an error on response timeout" do
    connection = Faraday::Connection.new
    allow(Faraday).to receive(:new).and_return(connection)
    allow(connection).to receive(:run_request).and_raise(Faraday::TimeoutError)
    @meteorological_data_service.get => { http_status:, error:, data: }
    expect(error).to eq "timeout"
  end

  it "does not set HTTP status on a response timeout" do
    connection = Faraday::Connection.new
    allow(Faraday).to receive(:new).and_return(connection)
    allow(connection).to receive(:run_request).and_raise(Faraday::TimeoutError)
    @meteorological_data_service.get => { http_status:, error:, data: }
    expect(http_status).to be_nil
  end

  it "logs requests" do
    VCR.use_cassette("open_meteo_meteorological_data_for_montpelier_vermont") do
      orig_logger = Rails.logger.dup
      logger_output = StringIO.new
      begin
        Rails.logger = ActiveSupport::Logger.new(logger_output)
        @meteorological_data_service.get
        expect(logger_output.string).to include "OpenMateo Meteorological Data Request"
        expect(logger_output.string).to include "GET https://api.open-meteo.com/v1/forecast?current=temperature_2m&daily=temperature_2m_max%2Ctemperature_2m_min&forecast_days=7&latitude=44.26380948438649&longitude=-72.5749091304874&temperature_unit=fahrenheit"
      ensure
        Rails.logger = orig_logger
      end
    end
  end
end
