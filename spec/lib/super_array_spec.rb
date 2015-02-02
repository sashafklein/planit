require 'spec_helper'

describe SuperArray do
  describe "initialization" do
    it "handles a deep array of whatever" do
      sa = SuperArray.new(array)
      expect( sa.first.k1 ).to eq 'value'
      expect( sa.first.k2.v.first ).to eq :b
      expect( sa.first.k2.v.last.d ).to eq ['a', 'b']
      expect( sa.first.k2.v.last['d'] ).to eq ['a', 'b']
      expect( sa.last ).to eq 'whatever'
    end

    it "initializes through a to function" do
      expect( array.to_sa ).to eq SuperArray.new(array)
      expect( array.to_sa.first.k2.v.last.d ).to eq ['a', 'b']
    end
  end

  def array
      SuperArray.new(
        [
          { 
            k1: 'value', 
            k2: { 
              v: [
                :b, 
                :c, 
                { d: ['a', 'b'] } 
              ] 
            } 
          }, 
          'whatever' 
        ]
      )
  end
end