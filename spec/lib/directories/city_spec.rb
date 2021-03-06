require 'rails_helper'

module Directories
  describe City do
    describe "find_in(string)" do
      it "finds San Francisco" do
        found = City.new.find_in("This is a string about San Francisco, California")
        expect( found.last[:accented] ).to eq "San Francisco"
      end

      it "finds Mumbai" do
        found = City.new.find_in("The city of Mumbai is a major city in India")
        expect( found.last[:accented] ).to eq "Mumbai"
      end

      it "finds Paris with a bad country" do
        found = City.new.find_in("This is a string about Paris Spain")
        expect( found.last[:accented] ).to eq "Paris"
      end
    end
  end
end