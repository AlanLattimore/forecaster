# frozen_string_literal: true

class OpenMeteoForecastService
  attr_reader :meteorological_data

  def initialize(meteorological_data:)
    @meteorological_data = meteorological_data
  end

  def forecast
    daily_data = meteorological_data["daily"]
    dates = daily_data["time"].map { |iso_8601_date| Date.parse(iso_8601_date) }
    highs = daily_data["temperature_2m_max"]
    lows = daily_data["temperature_2m_min"]
    Forecast.new(
      current: meteorological_data["current"]["temperature_2m"],
      high: highs.first,
      low: lows.first,
      seven_days: 7.times.map do |index|
        { date: dates[index], high: highs[index], low: lows[index] }
      end
    )
  end
end
