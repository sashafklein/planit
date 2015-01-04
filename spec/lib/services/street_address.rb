require 'spec_helper'

module Services
  describe StreetAddress, :vcr do 
    describe "parse!" do

      it "correctly parses SF home" do
        parser = StreetAddress.new("3976 23rd St, San Francisco, CA 94114")
        expect( parser.parse! ).to eq "3976 23rd St"
      end

      it "correctly parses Fuunji" do
        parser = StreetAddress.new("２丁目-14-3 Yoyogi, Shibuya, Tokyo 151-0053, Japan")
        expect( parser.parse! ).to eq "２丁目-14-3"
      end

      it "correctly parses Airbnb" do
        parser = StreetAddress.new("Calle 51 # 9-57 Apt 701, Bogota, Cundinamarca, Colombia,")
        expect( parser.parse! ).to eq "Calle 51 # 9-57 Apt 701"
      end

      it "correctly parses Teaism" do
        parser = StreetAddress.new("2009 R St NW Washington, DC 20009 b/t N Connecticut Ave & N 21st St in Dupont Circle")
        expect( parser.parse! ).to eq "2009 R St NW"
      end

      it "correctly parses Frenchie" do
        parser = StreetAddress.new("5-6 Rue du Nil, 75002 Paris, France")
        expect( parser.parse! ).to eq "5-6 Rue du Nil"
      end

      it "correctly parses Castro Theater" do
        parser = StreetAddress.new("429 Castro St, San Francisco, CA 94114")
        expect( parser.parse! ).to eq "429 Castro St"
      end

      it "correctly parses Mission Cliffs" do
        parser = StreetAddress.new("2295 Harrison Street San Francisco, CA 94110")
        expect( parser.parse! ).to eq "2295 Harrison Street"
      end

      it "correctly parses Grand Coffee" do
        parser = StreetAddress.new("2663 Mission St, San Francisco, CA 94110")
        expect( parser.parse! ).to eq "2663 Mission St"
      end

      it "correctly parses Petitenget, sorta" do
        parser = StreetAddress.new("Jl. Petitenget no. 40X, Kerobokan, Bali 80361, Indonesia")
        expect( parser.parse! ).to eq "Jl. Petitenget no. 40X, Kerobokan, Bali 80361"
      end

    end
  end
end