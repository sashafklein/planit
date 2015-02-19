require "rails_helper"

module PlaceMod
  describe Genre do
    describe "without database comparison" do
      describe "grabbing from other attrs" do

        it "gets 'San Francisco, California' from attributes" do
          place = Place.new(names: ["San Francisco, California"], locality: "San Francisco", region: 'California')
          assert_result(place, "Locality")
        end

        it "doesn't go with 'San Francisco' if it can't rule out other words" do
          place = Place.new(names: ["San Francisco, California"], locality: "San Francisco")
          assert_result(place, "Destination")
        end
      end

      describe "use of nearby" do
        it "takes a literal match, and still settles with the best area type" do
          place = Place.new(names: ["San Francisco, California"])
          assert_result(place, "Locality", "San Francisco California")
        end

        it "falls back to 'area' if the genre isn't clear" do
          place = Place.new( names: ["Blunderbus, Madeupplace"] )
          assert_result(place, 'Area', 'Blunderbus, Madeupplace')
        end
      end

      describe "use of city list" do
        it "uses city list for cities" do
          place = Place.new(names: ["San Francisco"])
          assert_result(place, "Locality")
        end

        it "uses city list for countries if it's found a city" do
          place = Place.new(names: ["San Francisco, United States of America"])
          assert_result(place, "Locality")
        end
      end

      describe "use of Carmen" do
        it "uses Carmen as a fallback to find countries that haven't been found" do
          place = Place.new( names: ["San Francisco United States"] )
          assert_result(place, "Locality")
        end

        it "uses country codes as well" do
          place = Place.new( names: ["San Francisco, US"])
          assert_result(place, "Locality")

          place2 = Place.new( names: ["San Francisco, USA"])
          assert_result(place2, "Locality")
        end
      end

      describe "fancy combinations" do
        it "can triangulate using multiple sources" do
          place = Place.new( names: ['Mission, San Francisco, California USA'], sublocality: 'Mission' )
          assert_result(place, "Sublocality", 'California')
        end
      end

      describe "multiple names" do
        it "grabs the most specific result" do
          place = Place.new( names: ["Contigo, Noe Valley, San Francisco", "Noe Valley, San Francisco"])
          assert_result( place, 'Destination', 'Noe Valley')
        end
      end

      describe "with a category" do
        it "overrides nearby if the category is there" do
          place = Place.new( names: ["John's Restaurant"])
          assert_result( place, "Destination", "John's Restaurant")
        end

        it "returns 'area' if it is an area category and it hasn't found anything else" do
          place = Place.new(names: ['Made up Town'])
          assert_result( place, 'Area')
        end
      end
    end

    def assert_result(place, genre, nearby=nil)
      expect( Genre.new(place, nearby).determine ).to eq genre
    end
  end
end