require 'spec_helper'

module Completers
  describe PlaceInProgress do

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
        })
      end
    end

    describe "#set_val(val)" do
      describe "acceptance" do
        it "enforces a hierarchy of acceptable sources" do
          @pip.set_val(:lat, 97, Narrow)
          expect(@pip.lat).to eq 97 # Narrow beats PlaceInProgress
          
          @pip.set_val(:lat, 100, Nearby)
          expect(@pip.lat).to eq 97 # Because Narrow beats Nearby, lat unchanged

          @pip.set_val(:lat, 100, Nearby, true)
          expect(@pip.lat).to eq 100 # Setting force to true overrides acceptance

          expect(@pip.attrs[:lat]).to eq({ val: 100, source: 'Nearby' })
        end
      end

      describe "duplication" do
        it "deduplicates arrays and keeps track of hash disagreements" do
          @pip.set_val(:flags, "This is a flag", Nearby)
          @pip.set_val(:flags, "Another flag", Nearby)
          @pip.update({ flags: "This is a flag" }, Nearby) # Doesn't double
          @pip.set_val(:hours, { mon: 'Whatever' }, Nearby)
          @pip.set_val(:hours, { mon: 'Whatever' }, Nearby)
          @pip.set_val(:hours, { mon: 'Whatever2' }, Narrow)

          expect( @pip.val(:flags) ).to eq ["This is a flag", "Another flag"]
          expect( @pip.val(:hours) ).to hash_eq( { mon: 'Whatever', mon_Narrow: 'Whatever2' } )
        end
      end
    end

    describe "#val(sym)" do
      it "extracts the value correctly, excluding the source" do
        expect( @pip.val(:names) ).to eq ["Whatever"]
        expect( @pip.val(:phones) ).to eq( ['123456789'] )
        expect( @pip.val(:lat) ).to eq 12.345678

        @pip.set_val(:lon, 2, Nearby)
        expect( @pip.val(:lon) ).to eq 2
      end
    end

    describe "#update" do
      it "updates values en masse, paying attention to acceptance" do
        @pip.update({ lat: 1, names: ["Another Whatever"]}, Narrow)
        expect(@pip.val(:lat)).to eq 1
        expect(@pip.val(:names)).to eq ["Whatever", "Another Whatever"]

        @pip.update({ lat: 2 }, Nearby)
        expect(@pip.val(:lat)).to eq 1 # Nearby is lower ranked, and should be rejected

        @pip.update({ lat: 2 }, Nearby, true)
        expect(@pip.val(:lat)).to eq 2 # Force override
      end
    end

    describe '#place' do
      it "initializes a place with all the right attributes" do
        expect(@pip.place).to be_a Place
        expect(@pip.place.lat).to eq @pip.val(:lat)
        expect(@pip.place.phones).to eq @pip.val(:phones)
      end
    end

  end
end