# frozen_string_literal: true

class Address
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :street, :string
  attribute :urb, :string
  attribute :city, :string
  attribute :municipio, :string
  attribute :state, :string
  attribute :zip, :string
  attribute :latitude, :float
  attribute :longitude, :float

  validates :street, presence: true
  validates :urb, :municipio, presence: true, if: -> (address) { address.urbanized? }
  validates :city, :state, presence: true, if: ->(address) { !address.urbanized? && address.zip.blank? }
  validates :zip, presence: true, unless: ->(address) { address.urbanized? || (address.city.present? && address.state.present?) }

  def urbanized?
    return false if zip.present?
    return false if city.present? && state.present?

    urb.present? || municipio.present?
  end

  def cache_key
    case
      when urbanized?
        "#{ zip }-#{ state }-#{ municipio }-#{ city }-#{ urb }-#{ street }"
      when zip.blank?
        "#{ state }-#{ city }-#{ street }"
      else
        "#{ zip }-#{ street }"
    end
  end
end
