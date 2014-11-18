require 'spec_helper'

module Services
  describe PlaceFinder do 
    describe 'find!' do

      before do 
        @mark = create(:mark, :with_place)
        allow_any_instance_of(PlaceMailer).to receive(:deliver) {}
      end

      context "with preexisting record without name clash - sends notification and" do

        before do 
          expect_any_instance_of(PlaceFinder).to( receive(:notify_of_merger) )
        end

        it "finds the mark by address" do
          found = PlaceFinder.new(attrs).find!
          expect( found ).to eq @mark.place
        end

        it "ignores improper data" do
          found = PlaceFinder.new(attrs({state: "StateIsNot AnAttribute", city: 'Neither Is City'})).find!
          expect( found ).to eq(@mark.place)
        end

        it "rounds out missing values in the place" do
          @mark.place.update_attribute(:website, '')
          expect( @mark.place.website ).to eq ''
          found = PlaceFinder.new( attrs({website: 'notblank.com'}) ).find!
          expect( found ).to eq @mark.place
          expect( found.website ).to eq 'notblank.com'
        end

        it "deals with nil country and region" do
          found = PlaceFinder.new( attrs({country: nil, region: nil}) ).find!
          expect( found ).to eq @mark.place
        end
      end

      context "with preexisting record with name clash" do

        before do 
          expect_any_instance_of(PlaceFinder).to( receive(:notify_of_name_clash ) ) {}
        end

        it "grabs and merges with the existing object and sends out merger notification" do
          found = PlaceFinder.new( attrs({names: ['Other name']}) ).find!
          expect( found ).not_to eq(@mark)
          expect( found.persisted? ).to eq true
          expect( found.names ).to eq @mark.place.names + ['Other name']
          expect( found.street_address ).to eq @mark.street_address
        end
      end

      context "without findable record" do

        it "takes lat lon plus street_address" do
          found = PlaceFinder.new( attrs({locality: nil, region: nil, street_addresses: ['123 Some Other Street'], lat: 123, lon: 123}) ).find!
          expect( found ).to be_a Place
          expect( found ).not_to be_persisted
        end

        it "takes name instead of street_address" do
          found = PlaceFinder.new(attrs({ street_address: nil, names: ["Something"] } )).find!
          expect( found ).to be_a Place
          found = PlaceFinder.new(attrs({ street_address: nil, locality: nil, region: nil, names: ["Something"], lat: 123, lon: 123 } )).find!
          expect( found ).to be_a Place
        end

        it "returns a new record" do
          attributes = attrs({street_addresses: ['123 Some Other Street']})
          found = PlaceFinder.new( attributes ).find!
          expect( found ).to be_a Place
          expect( found ).not_to be_persisted
          attributes.keys.each do |key|
            expect( found.send(key) ).to eq attributes[key]
          end
        end
      end
    end

    def attrs(to_merge={})
      {
        street_addresses: [@mark.street_address], country: @mark.country, locality: @mark.locality, region: @mark.region
      }.merge(to_merge).compact
    end
  end
end