require 'spec_helper'

module Services
  describe PlaceCompleter do 
    describe "complete!" do
      context "'fuzzy' finding with nearby attribute" do
        it "finds Florida House Inn (Amelia Island)", :vcr do
          place = PlaceCompleter.new( { name: 'Florida House Inn', street_address: "22 S 3rd St", nearby: 'Amelia Island, Fla.'}).complete!
          expect( place.country ).to eq('United States')
          expect( place.region ).to eq('Florida')
          expect( place.subregion ).to eq('Nassau County')
          expect( place.locality ).to eq('Fernandina Beach')
          expect( place.street_addresses ).to eq( ['22 S 3rd St', '20 S 3rd St'] )
          expect( place.names ).to eq( ['Florida House Inn', '1857 Florida House Inn'] )
          expect( place.phones ).to eq({})
          expect( place.category ).to eq('Hotel')
          expect( place.full_address ).to eq("22 South 3rd Street, Fernandina Beach, FL 32034, USA")
        end

        it "finds Fuunji", :vcr do
          place = PlaceCompleter.new( { name: 'Fuunji', nearby: 'Shibuya, Tokyo, Japan' }).complete!
          expect( place.country ).to eq('Japan')
          expect( place.region ).to eq('Tokyo')
          expect( place.subregion ).to eq(nil)
          expect( place.locality ).to eq('Shibuya')
          expect( place.street_addresses ).to eq( ["代々木2-14-3"] ) # Bonus -- should have "2 Chome-14 Yoyogi"
          expect( place.names ).to eq( ["Fuunji", "風雲児"] )
          expect( place.phones ).to eq({ default: "+81364138480" })
          expect( place.category ).to eq("Ramen / Noodle House")
        end

        it "locates and doesn't overwrite Cundinamarca AirBNB", :vcr do
          place = PlaceCompleter.new({ name: "Penthouse room with a view (Airbnb)", nearby: 'Bogota, Colombia', street_address: "701, 957 Calle 51", full_address: 'Calle 51 # 9-57 Apt 701, Bogota, Cundinamarca, Colombia' }).complete!
          expect( place.street_addresses ).to eq( ["701, 957 Calle 51"] )
          expect( place.names ).to eq( ["Penthouse room with a view (Airbnb)"] )
          expect( place.full_address ).to eq("Calle 51 # 9-57 Apt 701, Bogota, Cundinamarca, Colombia")
          expect( place.lat ).to eq(4.6379639)
          expect( place.lon ).to eq(-74.06488449999999)
        end

        it "finds Dwelltime" do
          place = PlaceCompleter.new({ name: "Dwelltime", nearby: 'Boston, MA'}).complete!
          # Wrong region information, different lat/lon
          binding.pry
          place = PlaceCompleter.new({ name: "Dwelltime", nearby: 'Cambridge, MA' }).complete!
          # Lat/lon off by a few blocks
          binding.pry

          place = PlaceCompleter.new({ name: "Dwelltime", nearby: 'Cambridge, MA', street_address: '364 Broadway'}).complete!
          # Works
          binding.pry

          expect(place.locality).to eq('Cambridge')
          expect(place.region).to eq("Massachusetts")
          expect(place.subregion).to eq("Middlesex County")
          expect(place.street_addresses).to eq([])
          expect(place.lat).to eq 42.370557650844894
          expect(place.lon).to eq -71.10438466072083
          expect(place.category).to eq 'Coffee Shop'
          expect(place.website).to eq 'http://dwelltimecambridge.com'
          expect(place.images.first).to eq 'https://irs3.4sqi.net/img/general/2000x200/6026_ruM6F73gjApA1zufxgbscViPgkbrP5HaYi_L8gti6hY.jpg'
        end

        xit 'finds La Cevicheria in Cartagena' do
          place = PlaceCompleter.new({name: 'La Cevicheria', street_address: "Calle Stuart No 7-14", nearby: "Cartagena, Colombia"} ).complete!
          
          expect( place.locality ).to eq "Cartagena"
          expect( place.country ).to eq "Colombia"
          expect( place.region ).to eq "Bolivar"
          expect( place.category ).to eq 'Seafood Restaurant'
          expect( place.street_addresses ).to eq ["Calle Stuart No 7-14", "Calle Stuart 7-14"]

          # expect( place.phones ).to eq( { default: "+5756645255" })
          expect( place.lat ).to eq 10.42786552 # Geocoder and Lonely Planet disagree
          expect( place.lon ).to eq -75.54796437
        end

        it "locates the Trident hotel in Mumbai, with 'Bombay' as nearby", :vcr do
          place = PlaceCompleter.new({ name: 'Trident Nariman Point', nearby: 'Bombay', street_address: 'Nariman Point, Mumbai, India'}).complete!
          expect( place.names ).to eq(["Trident Nariman Point", "The Trident"])
          expect( place.phones ).to eq({ default: '+912266324343'})
          expect( place.region ).to eq("Maharashtra")
          expect( place.street_addresses ).to eq(["Nariman Point, Mumbai, India", "Nariman Point"])
          expect( place.full_address ).to eq("Nariman Point, Mumbai, Maharashtra, India")
          expect( place.locality ).to eq("Mumbai")
          expect( place.category ).to eq("Hotel")
          expect( place.website ).to eq("http://www.tridenthotels.com")
          expect( place.lat ).to eq 18.9255728
          expect( place.lon ).to eq 72.8242221
        end
      end

      context "with preexisting place in db" do
        it "finds the Trident hotel with less information, and by either name", :vcr do
          place = PlaceCompleter.new({ name: 'Trident Nariman Point', nearby: 'Bombay', street_address: 'Nariman Point, Mumbai, India'}).complete!
          place2 = PlaceCompleter.new({ name: 'Trident Nariman Point', nearby: 'Mumbai'}).complete!
          place3 = PlaceCompleter.new({ name: 'The Trident', nearby: 'Bombay', street_address: 'Nariman Point, Mumbai, India'}).complete!
          expect( place ).to eq place2
          expect( place2 ).to eq place3
        end

        it "recognizes the varying Fuunjis", :vcr do
          place = PlaceCompleter.new({ name: 'Fuunji', nearby: 'Shinjuku, Tokyo' }).complete!
          place2 = PlaceCompleter.new({ name: 'Fu-Unji', nearby: 'Tokyo'}).complete!
          place3 = PlaceCompleter.new({ name: '風雲児', nearby: 'Tokyo, Japan'}).complete!
          binding.pry
          place4 = PlaceCompleter.new({ street_address: '代々木2-14-3', nearby: 'Tokyo, Japan' }).complete!
          binding.pry
          expect( place ).to eq place2
          expect( place2 ).to eq place3
          expect( place3 ).to eq place4
        end
      end

      describe "how it cleans/flattens incoming hash info", :vcr do
        it "turns excess into 'extra', and flattens name/street_address into names/street_addresses" do
          hash = {
            locality: 'Shibuya, Tokyo',
            name: 'Fuunji',
            names: ['Fu-Unji'],
            street_address: '代々木2-14-3',
            street_addresses: ["2 Chome-14 Yoyogi"],
            rating: 5,
            rating_tier: '5 star',
            twitter: '@fuunjiIsTheShit'
          }
          place = PlaceCompleter.new(hash).complete!
          expect( place.names.sort ).to eq ['Fuunji', 'Fu-Unji', '風雲児'].sort
          expect( place.street_addresses.sort ).to eq ['代々木2-14-3', "2 Chome-14 Yoyogi"].sort
          expect( place.extra.symbolize_keys ).to eq({ rating: '5', rating_tier: '5 star', twitter: '@fuunjiIsTheShit' })
        end
      end
    end
  end
end