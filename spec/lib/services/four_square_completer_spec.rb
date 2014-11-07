require 'spec_helper'

module Services
  describe FourSquareCompleter do
    describe "complete!" do
      context "with sufficient information" do

        it "returns a persisted place", :vcr do
          place = Place.new({lat: 37.74422249388305, lon: -122.4352317663816, names: ["Contigo"]})
          completed = FourSquareCompleter.new(place).complete!
          expect( completed ).to be_a Place
          expect( completed ).to be_persisted
        end

        it "completes with latLon and name", :vcr do
          place = Place.new({lat: 37.74422249388305, lon: -122.4352317663816, names: ["Contigo"]})
          f = FourSquareCompleter.new(place)
          completed = f.complete!

          expect(completed.street_address).to eq('1320 Castro St')
          expect(completed.phones).to eq( { default: "4152850250" } )
          expect(completed.category).to eq('Spanish Restaurant')
        end

        it "completes with locality and name", :vcr do
          place = Place.new({locality: 'Cartagena', country: 'Colombia', names: ["La Cevicheria"]})
          f = FourSquareCompleter.new(place)
          completed = f.complete!

          img = completed.images.first
          expect(img).to be_present
          expect( %w(png jpg jpeg) ).to include img.url.split('.').last
          expect(img.source).to eq 'FourSquare'

          expect(completed.category).to eq('Seafood Restaurant')
          expect(completed.country).to eq('Colombia')
          expect(completed.region).to eq('Bolívar')
        end
      end

      context "with insufficient information" do
        it "returns original without name" do
          place = Place.new({lat: 37.74422249388305, lon: -122.4352317663816})
          completed = FourSquareCompleter.new(place).complete!
          expect(completed).to eq( place )
        end

        it "returns original without locality" do
          place = Place.new({names: ["Contigo"], street_address: '1320 Castro St'})
          completed = FourSquareCompleter.new(place).complete!
          expect(completed).to eq(place)
        end
      end

      context "with unfindable information", :vcr do
        it "returns the original" do
          place = Place.new({names: ["ThisPlaceDoesntExist"], locality: 'San Francisco'})
          completed = FourSquareCompleter.new(place).complete!
          expect(completed).to eq(place)
        end
      end
    end
  end
end