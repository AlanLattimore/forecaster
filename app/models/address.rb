# frozen_string_literal: true

class Address
  include ActiveModel::Model

  attr_accessor :street, :urb, :city, :municipio, :state, :zip

  validates :street, presence: true
  validates :city, :state, presence: true, if: ->(address) { address.zip.blank? }
  validates :zip, presence: true, unless: ->(address) { address.city.present? && address.state.present? }
end
