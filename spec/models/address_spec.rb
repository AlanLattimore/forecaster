require "rspec"

RSpec.describe Address, type: :model do
  context "outside of Puerto Rico " do
    it "expects an address to be valid with only street and zip" do
      address = Address.new
      address.assign_attributes(street: "10 Main St.", zip: "12345")
      expect(address).to be_valid
    end

    it "expects an address to be valid with only street, city, and state" do
      address = Address.new
      address.assign_attributes(street: "10 Main St.", city: "Anytown", state: "PA")
      expect(address).to be_valid
    end

    it "expects an address to be invalid with only zip" do
      address = Address.new
      address.assign_attributes(zip: "12345")
      expect(address).to validate_presence_of :street
    end

    it "expects an address to be invalid with only city, state" do
      address = Address.new
      address.assign_attributes(city: "Anytown", state: "PA")
      expect(address).to validate_presence_of :street
    end
  end

  context "Puerto Rico Address" do
    it "expects an address with street and urb to be an urbanized address" do
      address = Address.new
      address.assign_attributes(street: "1234 Calle De Diego", urb: "Urbanizacion Comandante")
      expect(address.urbanized?).to be_truthy
    end

    it "expects an address with street and municipio to be an urbanized address" do
      address = Address.new
      address.assign_attributes(street: "1234 Calle De Diego", municipio: "Barrio Flores")
      expect(address.urbanized?).to be_truthy
    end

    it "expects an address with street and zip to not be an urbanized address" do
      address = Address.new
      address.assign_attributes(street: "1234 Calle De Diego", urb: "Urbanizacion Comandante", municipio: "Barrio Flores", zip: "00984")
      expect(address.urbanized?).to be_falsey
    end

    it "expects an address with street, city and state to not be an urbanized address" do
      address = Address.new
      address.assign_attributes(street: "1234 Calle De Diego", urb: "Urbanizacion Comandante", municipio: "Barrio Flores", city: "San Juan", state: "Puerto Rico")
      expect(address.urbanized?).to be_falsey
    end

    it "expects an Urbanized address to be valid with street, urb, and municipio" do
      address = Address.new
      address.assign_attributes(street: "1234 Calle De Diego", urb: "Urbanizacion Comandante", municipio: "Barrio Flores")
      expect(address.urbanized?).to be_truthy
      expect(address).to be_valid
    end

    it "expects an Urbanized address to be invalid without municipio" do
      address = Address.new
      address.assign_attributes(street: "1234 Calle De Diego", urb: "Urbanizacion Comandante")
      expect(address.urbanized?).to be_truthy
      expect(address).to validate_presence_of :municipio
    end

    it "expects an Urbanized address to be invalid without urb" do
      address = Address.new
      address.assign_attributes(street: "1234 Calle De Diego", municipio: "Barrio Flores")
      expect(address.urbanized?).to be_truthy
      expect(address).to validate_presence_of :urb
    end

    it "expects an non-Urbanized address to be valid with only street and zip" do
      address = Address.new
      address.assign_attributes(street: "1234 Calle De Diego", zip: "00984")
      expect(address.urbanized?).to be_falsey
      expect(address).to be_valid
    end

    it "expects an non-Urbanized address to be valid with only street, city and state" do
      address = Address.new
      address.assign_attributes(street: "1234 Calle De Diego", city: "San Juan", state: "Puerto Rico")
      expect(address.urbanized?).to be_falsey
      expect(address).to be_valid
    end
  end
end
