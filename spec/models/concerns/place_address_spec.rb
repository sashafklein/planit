require 'spec_helper'

describe PlaceAddress do 
  describe "format" do
    describe "directionals" do
      it "handles all of them" do
        expect( format("100 N Elm Street") ).to eq "100 North Elm Street"
        expect( format("100 NE Elm Street") ).to eq "100 Northeast Elm Street"
        expect( format("100 E Elm Street") ).to eq "100 East Elm Street"
        expect( format("100 SE Elm Street") ).to eq "100 Southeast Elm Street"
        expect( format("100 S Elm Street") ).to eq "100 South Elm Street"
        expect( format("100 SW Elm Street") ).to eq "100 Southwest Elm Street"
        expect( format("100 W Elm Street") ).to eq "100 West Elm Street"
        expect( format("100 NW Elm Street") ).to eq "100 Northwest Elm Street"
      end

      it "doesn't fuck with streets disguised as directionals" do
        expect( format("100 N N Street") ).to eq "100 North N Street"
        expect( format("100 NE N Street") ).to eq "100 Northeast N Street"
        expect( format("100 E N Street") ).to eq "100 East N Street"
        expect( format("100 SE N Street") ).to eq "100 Southeast N Street"
        expect( format("100 S N Street") ).to eq "100 South N Street"
        expect( format("100 SW N Street") ).to eq "100 Southwest N Street"
        expect( format("100 W N Street") ).to eq "100 West N Street"
        expect( format("100 NW N Street") ).to eq "100 Northwest N Street"
        expect( format("200 S Street NW") ).to eq "200 S Street Northwest"
        expect( format("200 S St NW") ).to eq "200 S Street Northwest"
        expect( format('123 S S St') ).to eq "123 South S Street"
        expect( format('123 S S Street') ).to eq "123 South S Street"
      end
    end

    describe "street abbreviations" do
      it "handles lots of different abbreviations" do
        # expect( format("2425 Wyoming Ave NW") ).to eq "2425 Wyoming Avenue Northwest"
        # expect( format("2425 Madeup Bland St") ).to eq "2425 Madeup Bland Street"
        # expect( format("2425 Bullshit Blvd") ).to eq "2425 Bullshit Boulevard"
        expect( format("2425 Sneaky St.") ).to eq "2425 Sneaky Street"
      end

      it "doesn't fuck up St (saint)" do
        expect( format("666 St Anselm St") ).to eq "666 St Anselm Street"
      end
    end
  end
end

def format(string)
  PlaceAddress.new(string).format
end