# frozen_string_literal: true

require "rails_helper"

RSpec.describe OpenMeteoForecastService do
  before do
    data = {
      "latitude" => 44.274887,
      "longitude" => -72.57745,
      "generationtime_ms" => 0.07796287536621094,
      "utc_offset_seconds" => 0,
      "timezone" => "GMT",
      "timezone_abbreviation" => "GMT",
      "elevation" => 228.0,
      "current_units" => {
        "time" => "iso8601",
        "interval" => "seconds",
        "temperature_2m" => "°F"
      },
      "current" => {
        "time" => "2024-08-20T16:45",
        "interval" => 900,
        "temperature_2m" => 57.5
      },
      "daily_units" => {
        "time" => "iso8601",
        "temperature_2m_max" => "°F",
        "temperature_2m_min" => "°F"
      },
      "daily" => {
        "time" => [
          "2024-08-20",
          "2024-08-21",
          "2024-08-22",
          "2024-08-23",
          "2024-08-24",
          "2024-08-25",
          "2024-08-26"
        ],
        "temperature_2m_max" => [
          60.5,
          58.8,
          63.5,
          76.1,
          78.5,
          77.2,
          77.7
        ],
        "temperature_2m_min" => [
          53.0,
          51.6,
          50.8,
          47.1,
          52.7,
          54.3,
          56.4
        ]
      }
    }
    @service = OpenMeteoForecastService.new(meteorological_data: data)
  end

  it "returns a Forecast" do
    expect(@service.forecast).to be_an_instance_of(Forecast)
  end

  it "has the current temperature" do
    expect(@service.forecast.current).to eq 57.5
  end

  it "has the expected daily high" do
    expect(@service.forecast.high).to eq 60.5
  end

  it "has the expected daily low" do
    expect(@service.forecast.low).to eq 53.0
  end

  it "has the extended forecast" do
    expect(@service.forecast.seven_days).to be_a Array
    expect(@service.forecast.seven_days.size).to eq 7
    expect(@service.forecast.seven_days.last).to be_a Hash
    expect(@service.forecast.seven_days.last[:date]).to eq Date.new(2024, 8, 26)
    expect(@service.forecast.seven_days.last[:high]).to eq 77.7
    expect(@service.forecast.seven_days.last[:low]).to eq 56.4
  end
end
