# frozen_string_literal: true

# A class to encapsulate a forecast, including the current temperature, today's
#   high & low, and an extended 7 day forecast
class Forecast
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :current, :float
  attribute :high, :float
  attribute :low, :float

  # @return [Array(Hash{Key=>value})]
  attribute :seven_days, array: true, default: []
end
