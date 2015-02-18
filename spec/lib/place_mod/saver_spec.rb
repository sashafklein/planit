require 'rails_helper'

module PlaceMod
  describe Saver do
    it "fixes everything", :vcr do
      place = Place.new(
        street_addresses: ['123 S S St', '123 S S Street'],
        full_address: '123 S S St. (at W St.), Seattle WA',
        categories: ['cafe', "Café"],
        phones: ['(123)-456-7890'],
        names: ['宏伊国', 'English Name', 'English name'],
        locality: 'Séattle',
        region: 'WA',
        country: 'US',
        lat: 47.6243785,
        lon: -122.3456918,
      )

      p = Saver.new(place).save!

      expect( p.street_addresses ).to eq ['123 South S Street']
      expect( p.full_address ).to eq '123 South S Street (at W Street), Seattle WA'
      expect( p.categories ).to eq ["Cafe"]
      expect( p.phones ).to eq ['1234567890']
      expect( p.names ).to eq ['English Name', '宏伊国']
      expect( p.locality ).to eq 'Seattle'
      expect( p.region ).to eq 'Washington'
      expect( p.country ).to eq "United States"
      expect( p.timezone_string ).to eq 'America/Los_Angeles'
    end
  end
end