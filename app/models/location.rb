# frozen_string_literal: true

# A lightweight class to encapsulate geolocation information.
class Location
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :zip, :string
  attribute :longitude, :float
  attribute :latitude, :float
end
