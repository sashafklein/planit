require 'rails_helper'

describe TrackHash do
  before do 
    @attrs = {phones: ['123456789'], lat: 12.345678, names: ["Whatever"]}
    hierarchy = %w( First Second Third )
    @th = TrackHash.new(defaults: Place.new.attributes, attrs: @attrs, acceptance_hierarchy: hierarchy)
  end

  describe "initialization" do
    it "sets and sources default and given attributes" do
      expect( @th.lat ).to eq @attrs[:lat]
      expect( @th.names ).to eq @attrs[:names]
      expect( @th.source(:lat) ).to eq 'First'
      expect( @th.source(:names) ).to eq ['First']
      expect( @th.source(:phones) ).to eq( ['First'] )

      expect( @th.lon ).to eq nil
      expect( @th.categories ).to eq []
      expect( @th.hours ).to eq( {} )

      expect( @th.attrs.reject{ |k, v| v.blank? } ).to hash_eq({
        lat: { val: @attrs[:lat], source: 'First' },
        names: [{ val: @attrs[:names], source: 'First' }],
        phones:[{ val: @attrs[:phones],source: 'First' }],
      }, [:feature_type, :published])
    end

    it "lets you set instance variable pairs" do
      th = TrackHash.new(defaults: Place.new.attributes, attrs: @attrs, instance_vars: { things: [1,2,3,4] })
      expect( th.things ).to eq [1,2,3,4]
      th.things = th.things + [5]
      expect( th.things ).to eq [1,2,3,4,5]

      th2 = TrackHash.new(defaults: Place.new.attributes)
      expect{ th2.things }.to raise_error NameError
    end
  end

  describe "#set_val(val)" do
    describe "acceptance" do
      it "enforces a hierarchy of acceptable sources" do
        @th.set_val( field: :lat, val:  97, source: 'Third')
        expect(@th.lat).to eq 97 # Third beats First
        
        @th.set_val( field: :lat, val:  100, source: 'Second')
        expect(@th.lat).to eq 97 # Because Third beats Second, lat unchanged

        @th.set_val( field: :lat, val:  100, source: 'Second', hierarchy_bump: 5)
        expect(@th.lat).to eq 100 # Setting hierarchy_bump up overrides acceptance

        expect(@th.attrs[:lat]).to eq({ val: 100, source: 'Second' })
      end
    end

    describe "duplication" do
      it "deduplicates arrays and keeps track of hash disagreements" do
        @th.set_val( field: :hours, val: { mon: 'Whatever' }, source: 'Second')
        @th.set_val( field: :hours, val: { mon: 'Whatever' }, source: 'Second')
        @th.set_val( field: :hours, val: { mon: 'Whatever2' }, source: 'Third')

        expect( @th.val(:hours) ).to hash_eq( { mon: 'Whatever', mon_Third: 'Whatever2' } )
      end
    end
  end

  describe "#val(sym)" do
    it "extracts the value correctly, excluding the source" do
      expect( @th.val(:names) ).to eq ["Whatever"]
      expect( @th.val(:phones) ).to eq( ['123456789'] )
      expect( @th.val(:lat) ).to eq 12.345678

      @th.set_val( field: :lon, val: 2, source: 'Second')
      expect( @th.val(:lon) ).to eq 2
    end
  end

end