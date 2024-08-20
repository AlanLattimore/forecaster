# frozen_string_literal: true

class Location
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :zip, :string
  attribute :longitude, :float
  attribute :latitude, :float
end
