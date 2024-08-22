# frozen_string_literal: true

# A class representing an US address including Puerto Rico.
# An Urbanized address must have at least street, urb, and municipio.
# Other addresses must have either street and zip OR street, city, and state at a minumum.
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

  # A predicate reflecting whether an address should be treated as a urbanized or not.
  # @return [Boolean] true if the address should be treated as urbanized.
  def urbanized?
    return false if zip.present?
    return false if city.present? && state.present?

    urb.present? || municipio.present?
  end

  # Calcualate a suitable cache key based on the 3 valid types of addresses.
  # @return [String] a cache key suited for caching address associated information such as longitude/latitude
  #   from a geolocation service
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
