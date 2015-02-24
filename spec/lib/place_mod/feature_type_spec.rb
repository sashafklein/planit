require "rails_helper"

module PlaceMod
  describe FeatureType do
    describe "without database comparison" do
      describe "grabbing from other attrs" do

        it "gets 'San Francisco, California' from attributes" do
          place = Place.new(names: ["San Francisco, California"], locality: "San Francisco", region: 'California')
          assert_result place: place, expectation: "Locality"
        end

        it "doesn't go with 'San Francisco' if it can't rule out other words" do
          place = Place.new(names: ["San Francisco, California"], locality: "San Francisco")
          assert_result place: place, expectation: "Destination"
        end

        it "finds region from the object" do
          place = Place.new( names: ["California, USA"], region: "California" )
          assert_result place: place, expectation: 'Region'
        end
      end

      describe "use of nearby" do
        it "takes a literal match, and still settles with the best area type" do
          place = Place.new(names: ["San Francisco, California"])
          assert_result place: place, expectation: "Locality", nearby: "San Francisco California"
        end

        it "falls back to 'area' if the genre isn't clear" do
          place = Place.new( names: ["Blunderbus, Madeupplace"] )
          assert_result place: place, expectation: 'Area', nearby: 'Blunderbus, Madeupplace'
        end

        it "chooses the finest grain calculation, even if Nearby might be smaller" do
          place = Place.new( names: ["Hells Kitchen New York"])
          assert_result place:  place, expectation: "Locality", nearby: "Hell's Kitchen"
        end
      end

      describe "use of city list" do
        it "uses city list for cities" do
          place = Place.new(names: ["San Francisco"])
          assert_result place: place, expectation: "Locality"
        end

        it "uses city list for countries if it's found a city" do
          place = Place.new(names: ["San Francisco, United States of America"])
          assert_result place: place, expectation: "Locality"
        end

        it "gets Tokyo" do
          place = Place.new(names: ["Tokyo Japan"])
          assert_result place: place, expectation: "Locality"
        end

        it "gets Japan" do
          place = Place.new(names: ["Japan"])
          assert_result place: place, expectation: "Country"
        end

        it "chooses the correct spelling" do
          place = Place.new(names: ['Marrakech, Morocco'])
          assert_result place: place, expectation: 'Locality'
        end
      end

      describe "use of Carmen" do
        it "uses Carmen as a fallback to find countries that haven't been found" do
          place = Place.new( names: ["San Francisco United States"] )
          assert_result place: place, expectation: "Locality"
        end

        it "finds kyoto jp" do
          place = Place.new( names: ["Kyoto JP"])
          assert_result place: place, expectation: "Locality"
        end

        it "uses country codes as well" do
          place = Place.new( names: ["San Francisco, US"])
          assert_result place: place, expectation: "Locality"

          place2 = Place.new( names: ["San Francisco, USA"])
          assert_result place: place2, expectation: "Locality"
        end
      end

      describe "fancy combinations" do
        it "can triangulate using multiple sources" do
          place = Place.new( names: ['Mission, San Francisco, California USA'], sublocality: 'Mission' )
          assert_result place: place, expectation: "Sublocality", nearby: 'California'
        end
      end

      describe "multiple names" do
        it "grabs the most specific result" do
          place = Place.new( names: ["Contigo, Noe Valley, San Francisco", "Noe Valley, San Francisco"])
          assert_result place: place, expectation: 'Destination', nearby: 'Noe Valley'
        end
      end

      describe "with a category" do

        it "overrides nearby if the category is there" do
          place = Place.new( names: ["John's Restaurant"])
          assert_result place: place, expectation: "Destination", nearby: "John's Restaurant"
        end
      end

      describe "with anything other than complete location overlap" do
        it "returns destination" do
          place = Place.new( names: ["New York Blah United States"] )
          assert_result place: place, expectation: "Destination"
        end

        it "returns destination (again)" do
          place = Place.new( names: ["Budapest Foo Hungary"] )
          assert_result place: place, expectation: "Destination"
        end
      end
    end

    def assert_result(place:, expectation:, nearby: nil)
      expect( FeatureType.new(place, nearby).determine ).to eq expectation
    end
  end
end