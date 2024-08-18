# frozen_string_literal: true

class Address
  include ActiveModel::Model

  attr_accessor :street, :urb, :city, :municipio, :state, :zip

  validates :street, presence: true
  validates :urb, :municipio, presence: true, if: -> (address) { address.urbanized? }
  validates :city, :state, presence: true, if: ->(address) { !address.urbanized? && address.zip.blank? }
  validates :zip, presence: true, unless: ->(address) { address.urbanized? || (address.city.present? && address.state.present?) }

  def urbanized?
    return false if zip.present?
    return false if city.present? && state.present?

    urb.present? || municipio.present?
  end
end
