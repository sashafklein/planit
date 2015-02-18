require 'rails_helper'

module PlaceMod
  describe Finder do 
    describe 'find!' do

      before do 
        @mark = create(:mark)
      end

      context "with preexisting record without name clash" do

        it "finds the mark by address" do
          found = Finder.new(attrs).find!
          expect( found ).to eq @mark.place
        end

        it "ignores improper data" do
          found = Finder.new(attrs({state: "StateIsNot AnAttribute", city: 'Neither Is City'})).find!
          expect( found ).to eq(@mark.place)
        end

        it "rounds out missing values in the place" do
          @mark.place.update_attribute(:website, '')
          expect( @mark.place.website ).to eq ''
          found = Finder.new( attrs({website: 'notblank.com'}) ).find!
          expect( found ).to eq @mark.place
          expect( found.website ).to eq 'notblank.com'
        end

        it "deals with nil country and region" do
          found = Finder.new( attrs({country: nil, region: nil}) ).find!
          expect( found ).to eq @mark.place
        end

      end

      context "with preexisting record with name clash" do

        before do 
          expect_any_instance_of(Finder).to( receive(:notify_of_name_clash ) ) {}
        end

        it "notifies of a merger if a name is added" do
          found = Finder.new( attrs({names: [@mark.name, "OtherName"]}) ).find!
          expect( found ).to eq @mark.place
        end
      end

      context "without a name" do
        it "doesn't find a place without a name" do
          found = Finder.new( attrs({ names: [] }) ).find!
          expect( found ).not_to eq @mark.place
          expect( found ).not_to be_persisted
          expect( found.street_address ).to eq @mark.place.street_address
        end

        it "makes an exception for foursquare_id, which is sufficient alone" do
          found = Finder.new( foursquare_id: 'abcde12345' ).find!
          expect( found ).to eq @mark.place
        end
      end
      
      context "without findable record" do

        it "takes lat lon plus street_address" do
          found = Finder.new( attrs({locality: nil, region: nil, street_addresses: ['123 Some Other Street'], lat: 123, lon: 123}) ).find!
          expect( found ).to be_a Place
          expect( found ).not_to be_persisted
        end

        it "takes name instead of street_address" do
          found = Finder.new(attrs({ street_address: nil, names: ["Something"] } )).find!
          expect( found ).to be_a Place
          found = Finder.new(attrs({ street_address: nil, locality: nil, region: nil, names: ["Something"], lat: 123, lon: 123 } )).find!
          expect( found ).to be_a Place
        end

        it "returns a new record" do
          attributes = attrs({street_addresses: ['123 Some Other Street']})
          found = Finder.new( attributes ).find!
          expect( found ).to be_a Place
          expect( found ).not_to be_persisted
          attributes.keys.each do |key|
            expect( found.send(key) ).to eq attributes[key]
          end
        end
      end

      context "the Vancouver Starbucks test" do

        before do 
          @atts = {cross_street: 'at Heather St', country: 'Canada', region: "British Columbia", locality: "Vancouver", lat: 49.26293173490001, lon: -123.11948776245117, timezone_string: "America/Vancouver", names: ["Starbucks"], street_addresses: ["682 W Broadway"], full_address: "682 W Broadway, Vancouver, Canada", categories: ["Coffee Shop"], meta_categories: ["Food"], phones: ["6047080030"]}.to_sh
          @sb = Place.create( @atts )
        end

        it "finds with name and street address" do
          expect( search( :names, :street_addresses )).to eq @sb
        end
        
        it "finds with name and full_address" do
          expect( search( :names, :full_address )).to eq @sb
        end
        
        it "finds with name and lat and lon" do
          expect( search( :names, :lat, :lon ) ).to eq @sb
        end

        it "finds with name and cross street and locality" do
          expect( search( :names, :cross_street, :locality )).to eq @sb
        end
        
        it "finds with name and phones" do
          expect( search( :names, :phones )).to eq @sb
        end

        it "doesn't find without name, no matter what else" do
          expect( search( :phones, :sublocality, :locality, :region, :country, :cross_street, :phones, :lat, :on )).not_to be_persisted
        end

        it "doesn't find if it doesn't have a specific addressing piece" do
          expect( search( :names, :locality, :sublocality, :region, :country )).not_to be_persisted
        end
      end
    end

    def search(*atts_to_slice)
      Finder.new(@atts.slice(*atts_to_slice)).find!
    end

    def attrs(to_merge={})
      {
        names: [@mark.name], street_addresses: [@mark.street_address], country: @mark.country, locality: @mark.locality, region: @mark.region
      }.merge(to_merge).compact
    end
  end
end