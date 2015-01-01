require 'spec_helper'

module Completers
  describe FourSquare do
    describe "complete!" do
      context "with sufficient information" do

        it "returns a non-persisted place", :vcr do
          pip = PlaceInProgress.new({lat: 37.74422249388305, lon: -122.4352317663816, names: ["Contigo"]})
          completed = FourSquare.new(pip).complete!
          c_place = completed[:place].place
          
          expect( c_place ).to be_a Place
          expect( c_place ).not_to be_persisted
        end

        it "completes with latLon and name", :vcr do
          pip = PlaceInProgress.new({lat: 37.750, lon: -122.434, names: ["Contigo"]})
          completed = FourSquare.new(pip).complete!
          c_place = completed[:place].place

          expect( c_place.street_address ).to eq('1320 Castro St')
          expect( c_place.phones ).to eq( { 'default' => "4152850250" } )
          expect( c_place.category ).to eq('Spanish Restaurant')
        end

        it "completes with locality and name", :vcr do
          pip = PlaceInProgress.new({locality: 'Cartagena', country: 'Colombia', names: ["La Cevicheria"]})
          completed = FourSquare.new(pip).complete!

          c_place = completed[:place].place

          img = completed[:photos].first
          expect(img).to be_present
          expect( %w(png jpg jpeg) ).to include img.url.split('.').last
          expect(img.source).to eq 'FourSquare'

          expect( c_place.category ).to eq('Seafood Restaurant')
          expect( c_place.country ).to eq('Colombia')
          expect( c_place.region ).to eq('Bolívar')
        end
      end

      context "with insufficient information" do
        it "returns original without name", :vcr do
          place = Place.new({lat: 37.74422249388305, lon: -122.4352317663816})
          pip = PlaceInProgress.new(place.attributes.symbolize_keys)
          completed = FourSquare.new(pip).complete!
          c_place = completed[:place].place

          expect( c_place.attributes ).to eq( place.attributes )
        end

        it "returns original without locality", :vcr do
          place = Place.new({names: ["Contigo"], street_addresses: ['1320 Castro St']})
          pip = PlaceInProgress.new(place.attributes.symbolize_keys)
          completed = FourSquare.new(pip).complete!
          c_place = completed[:place].place
          expect( c_place.attributes ).to eq(place.attributes)
        end
      end

      context "with unfindable information", :vcr do
        it "returns the original" do
          place = Place.new({names: ["ThisPlaceDoesntExist"], locality: 'San Francisco'})
          pip = PlaceInProgress.new(place.attributes.symbolize_keys)
          completed = FourSquare.new(pip).complete!
          c_place = completed[:place].place
          expect( c_place.attributes ).to eq(place.attributes)
        end
      end
    end
  end
end