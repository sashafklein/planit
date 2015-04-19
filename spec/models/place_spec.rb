require 'rails_helper'

describe Place do 
  describe "validations" do
    it "requires lat, lon, names feature_type, timezone_string" do
      expect( place                        ).to be_valid
      expect( place(no: :lat)              ).not_to be_valid
      expect( place(no: :lon)              ).not_to be_valid
      # expect( place(no: :country)          ).not_to be_valid
      # expect( place(no: :locality)         ).not_to be_valid
      expect( place(no: :names)            ).not_to be_valid
      expect( place(no: :timezone_string)  ).not_to be_valid
      expect( place(other: { feature_type: nil })  ).not_to be_valid
    end

    # xit "requires street_address if feature type is destination" do
    #   expect( place(                       other: { feature_type: 0 }) ).to be_valid
    #   expect( place(no: :street_addresses, other: { feature_type: 0 }) ).not_to be_valid
    #   expect( place(no: :street_addresses, other: { feature_type: 1 }) ).to be_valid
    # end
  end

  describe "correct_data_types(hash)" do
    it "fixes the data types while ignoring non-attributes keys" do
      result = Place.correct_data_types({
        lat: '123',
        lon: '1234.56',
        names: nil,
        full_address: 1234,
        feature_type: 1.2,
        made_up: { whatever: 'I want'}
      }).to_sh

      expect( result.lat ).to eq 123.0
      expect( result.lat ).to be_a Float
      expect( result.lon ).to eq 1234.56
      expect( result.names ).to eq []
      expect( result.full_address ).to eq '1234'
      expect( result.feature_type ).to eq 1
      expect( result.made_up ).to eq( { whatever: 'I want' } )
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