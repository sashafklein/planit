require 'rails_helper'

describe Place do 
  describe "validations" do
    it "basic validations -- lat, lon, names, country, locality, street_addresses" do
      expect( place                        ).to be_valid
      expect( place(no: :lat)              ).not_to be_valid
      expect( place(no: :lon)              ).not_to be_valid
      expect( place(no: :country)          ).not_to be_valid
      expect( place(no: :locality)         ).not_to be_valid
      expect( place(no: :names)            ).not_to be_valid
      expect( place(no: :street_addresses) ).not_to be_valid
      expect( place(no: :timezone_string)  ).not_to be_valid
    end
  end

  def place(no: nil)
    Place.new(
      {
        lat: 123, 
        lon: 123,
        names: ['Name'],
        country: 'USA',
        locality: 'Washington',
        street_addresses: ["1600 Penn Ave"],
        timezone_string: 'whatever'
      }.except(no)
    )
  end
end