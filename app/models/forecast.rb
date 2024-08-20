# frozen_string_literal: true

class Forecast
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :current, :float
  attribute :high, :float
  attribute :low, :float
  attribute :seven_days, array: true, default: []
end
