require 'rails_helper'

describe Place do 
  describe "validations" do
    it "requires lat, lon, names, country, locality, feature_type, timezone_string street_addresses" do
      expect( place                        ).to be_valid
      expect( place(no: :lat)              ).not_to be_valid
      expect( place(no: :lon)              ).not_to be_valid
      expect( place(no: :country)          ).not_to be_valid
      expect( place(no: :locality)         ).not_to be_valid
      expect( place(no: :names)            ).not_to be_valid
      expect( place(no: :timezone_string)  ).not_to be_valid
      expect( place(other: { feature_type: nil })  ).not_to be_valid
    end

    it "requires street_address if feature type is destination" do
      expect( place(                       other: { feature_type: 0 }) ).to be_valid
      expect( place(no: :street_addresses, other: { feature_type: 0 }) ).not_to be_valid
      expect( place(no: :street_addresses, other: { feature_type: 1 }) ).to be_valid
    end
  end

  def place(no: nil, other: {})
    Place.new(
      {
        lat: 123, 
        lon: 123,
        names: ['Name'],
        country: 'USA',
        locality: 'Washington',
        street_addresses: ["1600 Penn Ave"],
        timezone_string: 'whatever',
      }.except(no).merge(other)
    )
  end
end