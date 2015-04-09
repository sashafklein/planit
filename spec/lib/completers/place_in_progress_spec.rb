require 'rails_helper'

module Completers
  xdescribe PlaceInProgress do

    before do 
      @attrs = {phones: ['123456789'], lat: 12.345678, names: ["Whatever"]}
      @pip = PlaceInProgress.new(@attrs)
    end

    describe "initialization" do
      it "sets and sources default and given attributes" do
        expect( @pip.lat ).to eq @attrs[:lat]
        expect( @pip.names ).to eq @attrs[:names]
        expect( @pip.source(:lat) ).to eq "PlaceInProgress"
        expect( @pip.source(:names) ).to eq ["PlaceInProgress"]
        expect( @pip.source(:phones) ).to eq( ['PlaceInProgress'] )

        expect( @pip.lon ).to eq nil
        expect( @pip.categories ).to eq []
        expect( @pip.hours ).to eq( {} )

        expect( @pip.attrs.reject{ |k, v| v.blank? } ).to hash_eq({
          lat: { val: @attrs[:lat], source: "PlaceInProgress" },
          names: [{ val: @attrs[:names], source: "PlaceInProgress" }],
          phones:[{ val: @attrs[:phones],source: "PlaceInProgress" }]
        }, ignore_keys: [:feature_type, :published])
      end
    end

    describe "#set_val(val)" do
      describe "acceptance" do
        it "enforces a hierarchy of acceptable sources" do
          @pip.set_val(field: :lat, val: 97, source: 'Narrow')
          expect(@pip.lat).to eq 97 # Narrow beats PlaceInProgress
          
          @pip.set_val(field: :lat, val: 100, source:  'Nearby')
          expect(@pip.lat).to eq 97 # Because Narrow beats Nearby, lat unchanged

          @pip.set_val(field: :lat, val: 100, source: 'Nearby', hierarchy_bump: 5)
          expect(@pip.lat).to eq 100 # Setting hierarchy_bump to 5 overrides acceptance

          expect(@pip.attrs[:lat]).to eq({ val: 100, source: 'Nearby' })
        end
      end

      describe "duplication" do
        it "deduplicates arrays and keeps track of hash disagreements" do
          @pip.set_val(field: :hours, val: { mon: 'Whatever' }, source: 'Nearby')
          @pip.set_val(field: :hours, val: { mon: 'Whatever' }, source: 'Nearby')
          @pip.set_val(field: :hours, val: { mon: 'Whatever2' }, source: 'Narrow')

          expect( @pip.val(:hours) ).to hash_eq( { mon: 'Whatever', mon_Narrow: 'Whatever2' } )
        end
      end
    end

    describe "#val(sym)" do
      it "extracts the value correctly, excluding the source" do
        expect( @pip.val(:names) ).to eq ["Whatever"]
        expect( @pip.val(:phones) ).to eq( ['123456789'] )
        expect( @pip.val(:lat) ).to eq 12.345678

        @pip.set_val( field: :lon, val: 2, source: 'Nearby')
        expect( @pip.val(:lon) ).to eq 2
      end
    end

    describe '#place' do
      it "initializes a place with all the right attributes" do
        expect(@pip.place).to be_a Place
        expect(@pip.place.lat).to eq @pip.val(:lat)
        expect(@pip.place.phones).to eq @pip.val(:phones)
      end
    end

    describe "alternate store methods" do
      describe "#set_ds" do
        it "allows for specific storage and access" do
          @pip.set_ds(:foursquare_explore)
          expect( @pip.ds._name ).to eq "FoursquareExplore"
          @pip.set_val( field: :lon, val: 123, source: 'PlaceInProgress') 
          @pip.set_ds(:base)

          expect( @pip.lon ).to eq nil

          @pip.set_ds(:foursquare_explore)
          expect( @pip.source(:lon) ).to eq "PlaceInProgress"
        end
      end

      describe "flush!(ds)" do
        it "clears out a datastore" do
          @pip.set_ds(:foursquare_explore)
          @pip.set_val( field: :lon, val: 123, source: 'PlaceInProgress') 
          @pip.set_val( field: :lat, val: 123, source: 'PlaceInProgress') 
          expect( @pip.lat ).to eq 123
          expect( @pip.lon ).to eq 123

          @pip.flush!(:foursquare_explore)
          @pip.set_ds(:foursquare_explore)
          expect( @pip.lat ).to be_nil
          expect( @pip.lon ).to be_nil

          @pip.set_ds(:base)
          expect( @pip.lat ).to eq @attrs[:lat]
        end
      end

      describe "load_to_current!(from)" do
        it "loads in any additions from the side datastore" do
          @pip.set_ds(:other)
          @pip.set_val( field: :lon, val: 123, source: 'PlaceInProgress')
          @pip.set_val( field: :names, val: ['Another'], source: 'PlaceInProgress')
          @pip.load!(:other)

          expect( @pip.ds._name ).to eq 'Base'
          expect( @pip.names ).to include "Another"
          expect( @pip.lon ).to eq 123
        end
      end
    end

  end
end