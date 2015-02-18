require 'rails_helper'

module Completers
  describe PlaceCompleter, :vcr do 

    include ScraperHelper 

    describe "complete!" do
      context "'fuzzy' finding with nearby attribute" do
        it "finds Florida House Inn (Amelia Island)" do
          place = PlaceCompleter.new( { name: 'Florida House Inn', street_address: "22 S 3rd St", nearby: 'Amelia Island, Fla.'}).complete!
          expect( place.country ).to eq('United States')
          expect( place.region ).to eq('Florida')
          expect( place.subregion ).to eq('Nassau County')
          expect( place.locality ).to eq('Fernandina Beach')
          expect( place.street_addresses ).to eq( ['22 South 3rd Street', '20 South 3rd Street'] )
          expect( place.names ).to eq( ['Florida House Inn', '1857 Florida House Inn'] )
          expect( place.phones ).to eq( [] )
          expect( place.phone ).to eq nil
          expect( place.category ).to eq('Hotel')
          expect( place.full_address ).to eq("20 South 3rd Street, Amelia Island, FL 32034")
          expect( place.meta_category ).to eq('Stay')
        end

        it "finds Fuunji" do
          place = PlaceCompleter.new( { name: 'Fuunji', nearby: 'Shibuya, Tokyo, Japan' }, 'whatever.com').complete!
          expect( place.country ).to eq('Japan')
          expect( place.region ).to eq('Tokyo-to')
          expect( place.subregion ).to eq(nil)
          expect( place.locality ).to eq('Shibuya-ku')
          expect( place.street_addresses ).to eq( ["代々木2-14-3", "2 Chome-１４−3 Yoyogi"] )
          expect( place.names ).to eq( ["Fuunji", "風雲児"] )
          expect( place.phones ).to eq(["81364138480"])
          expect( place.category ).to eq("Ramen / Noodle House")
          expect( place.meta_categories ).to eq(['Food'])
          expect( place.meta_category ).to eq('Food')
          expect( place.hours ).to hash_eq({
            "mon"=>[["1100", "1500"], ["1700", "2100"]],
            "tue"=>[["1100", "1500"], ["1700", "2100"]],
            "wed"=>[["1100", "1500"], ["1700", "2100"]],
            "thu"=>[["1100", "1500"], ["1700", "2100"]],
            "fri"=>[["1100", "1500"], ["1700", "2100"]],
            "sat"=>[["1100", "1500"], ["1700", "2100"]]
          })
          expect( place.scrape_url ).to eq 'whatever.com'
        end

        it "locates and doesn't overwrite Cundinamarca AirBNB" do
          place = PlaceCompleter.new({ name: "Penthouse room with a view (Airbnb)", nearby: 'Bogota, Colombia', street_address: "701, 957 Calle 51", full_address: 'Calle 51 # 9-57 Apt 701, Bogota, Cundinamarca, Colombia' }).complete!
          expect( place.street_addresses ).to eq( ["701, 957 Calle 51"] )
          expect( place.names ).to eq( ["Penthouse room with a view (Airbnb)"] )
          expect( place.full_address ).to eq("Calle 51 # 9-57 Apt 701, Bogota, Cundinamarca, Colombia")
          expect( place.lat ).to be_within(0.000001).of(4.6379639)
          expect( place.lon ).to be_within(0.000001).of(-74.0648845)
        end

        it 'finds La Cevicheria in Cartagena' do
          place = PlaceCompleter.new({name: 'La Cevicheria', street_address: "Calle Stuart No 7-14", nearby: "Cartagena, Colombia"} ).complete!
          
          expect( place.locality ).to eq "Cartagena De Indias"
          expect( place.country ).to eq "Colombia"
          expect( place.region ).to eq "Bolivar"
          expect( place.category ).to eq 'Seafood Restaurant'
          expect( place.street_addresses ).to eq ["Calle Stuart No 7-14", "Calle Stuart 7-14"]
          expect( place.lat ).to eq 10.428036
          expect( place.lon ).to eq -75.548012
        end

        it "locates the Trident hotel in Mumbai, with 'Bombay' as nearby" do
          place = PlaceCompleter.new({ name: 'Trident Nariman Point', nearby: 'Bombay', street_address: 'Nariman Point, Mumbai, India'}).complete!
          expect( place.names ).to eq(["Trident Nariman Point", "The Trident"])
          expect( place.reload.phones ).to eq(["912266324343"])
          expect( place.region ).to eq("Maharashtra")
          expect( place.street_addresses ).to eq(["Nariman Point, Mumbai, India", "Nariman Point"])
          expect( place.locality ).to eq("Mumbai")
          expect( place.category ).to eq('Hotel')
          expect( place.website ).to eq("http://www.tridenthotels.com")
          expect( place.lat ).to be_within(0.01).of(18.9255728)
          expect( place.lon ).to be_within(0.01).of(72.8242221)
          expect( place.meta_category ).to eq('Stay')
        end

        it "locates Caffe Vita Inc and fills out the category" do
          place = PlaceCompleter.new(yml_data('nikoklein', 'http://www.googlemaps.com/', "Caffe Vita Inc")[:place]).complete!
          expect( place.postal_code ).to eq "98103"
          expect( place.cross_street ).to eq "at N 43rd St"
          expect( place.country ).to eq "United States"
          expect( place.region ).to eq "Washington"
          expect( place.locality ).to eq "Seattle"
          expect( place.lat ).to be_within(0.03).of 47.659109
          expect( place.lon ).to be_within(0.03).of -122.3503097
          expect( place.website ).to eq "http://www.caffevita.com"
          expect( place.names ).to eq ["Caffe Vita Inc", "Caffé Vita"]
          expect( place.phones ).to eq(["2066323535"])
          expect( place.hours ).to hash_eq( {
            "mon"=>[["0600", "2000"]], 
            "tue"=>[["0600", "2000"]], 
            "wed"=>[["0600", "2000"]], 
            "thu"=>[["0600", "2000"]], 
            "fri"=>[["0600", "2000"]], 
            "sat"=>[["0700", "2000"]], 
            "sun"=>[["0700", "2000"]]
          } )
          expect( place.subregion ).to eq "King County"
          expect( place.street_addresses ).to eq ["4301 Fremont Avenue North"]
          expect( place.full_address ).to eq "4301 Fremont Avenue North (at North 43rd St), Seattle, WA 98103"
          expect( place.categories ).to eq ["Coffee Shop"]
          expect( place.wifi ).to eq false
          expect( place.foursquare_id ).to eq "4a7f3209f964a5203bf31fe3"
          expect( place.timezone_string ).to eq "America/Los_Angeles"
        end

        it "locates Trocadero Club and fills out the category" do
          place = PlaceCompleter.new(yml_data('nikoklein', 'http://www.googlemaps.com/', "Trocadero Club")[:place]).complete!
          expect( place.completion_steps ).not_to include 'FoursquareExplore' # Trocadero Club has closed
        end

        it "saves hours as a hash, accessable as a deep struct" do
          place = PlaceCompleter.new(yml_data('comptoir', 'http://www.yelp.com/biz/le-comptoir-du-relais-paris')[:place]).complete!
          expect(place.hours).to hash_eq({
            'mon' => [["1200","0000"]],
            'tue' => [["1200","0000"]],
            'wed' => [["1200","0000"]],
            'thu' => [["1200","0000"]],
            'fri' => [["1200","0000"]],
            'sat' => [["1200","0200"]],
            'sun' => [["1200","0000"]]
          })
          expect( place.hours.mon.first.first ).to eq("1200")
        end

        it "flips L/L if needed (e.g. Gâteaux Thoumieux in Mogadishu)" do
          place = PlaceCompleter.new(yml_data('thoumieux-flipped', 'http://www.eater.com/', "Gâteaux Thoumieux")[:place]).complete!
          expect( place.lat ).to be_within(0.01).of(48.85989163257022)
          expect( place.lon ).to be_within(0.01).of(2.3091419555351185)
          expect( place.flags.find_by(name: "Invalid LatLon found").description ).to eq "Invalid LatLon found - Cleared out LatLon in PlaceMod::Attrs"
          expect( place.completion_steps ).to eq ["GoogleMaps", "FoursquareExplore", "FoursquareRefine", "TranslateAndRefine"]
          expect( place.hours ).to hash_eq({
            "mon"=>[["1000", "2000"]], 
            "wed"=>[["1000", "2000"]], 
            "thu"=>[["1000", "2000"]], 
            "fri"=>[["1000", "2000"]], 
            "sat"=>[["1000", "2000"]], 
            "sun"=>[["0830", "1700"]]
          })
          expect( place.region ).to eq 'Ile-de-France'
          expect( place.categories ).to eq ['Dessert Shop']
          expect( place.meta_category ).to eq 'Food'
          expect( place.timezone_string ).to eq 'Europe/Paris'
          expect( place.phones ).to eq ["33145511212"]
        end

        it "ensures L/L exists within natural bounds (e.g. Apizza Scholls in Antartica) or discards" do
          place = PlaceCompleter.new(yml_data('apizza-scholls-flipped', 'http://www.eater.com/', "Apizza Scholls")[:place]).complete!
          expect( place.lat ).to be_within(0.01).of(45.512043)
          expect( place.lon ).to be_within(0.01).of(-122.613144)
          expect( place.flags.find_by(name: "Invalid LatLon found").description ).to eq("Invalid LatLon found - Cleared out LatLon in PlaceMod::Attrs")
          expect( place.menu ).to eq "https://foursquare.com/v/apizza-scholls/4293c000f964a52038241fe3/menu"
          expect( place.mobile_menu ).to eq "https://foursquare.com/v/4293c000f964a52038241fe3/device_menu"
          expect( place.foursquare_id ).to eq "4293c000f964a52038241fe3"
          expect( place.timezone_string ).to eq "America/Los_Angeles"
          expect( place.website ).to eq "http://www.apizzascholls.com/"
          expect( place.reservations ).to eq true
          expect( place.reservations_link ).to eq nil
          expect( place.categories ).to eq( ["Pizza Place"] )
          expect( place.meta_categories ).to eq( ["Food"] )
          expect( place.street_address ).to eq "4741 Southeast Hawthorne Boulevard"
          expect( place.locality ).to eq "Portland"
          expect( place.region ).to eq "Oregon"
          expect( place.hours ).to hash_eq({
            "mon"=>[["1700", "2130"]],
            "tue"=>[["1700", "2130"]],
            "wed"=>[["1700", "2130"]],
            "thu"=>[["1700", "2130"]],
            "fri"=>[["1700", "2130"]],
            "sat"=>[["1700", "2130"]],
            "sun"=>[["1600", "2000"]]
          })
          expect( place.phones ).to eq ["5032331286"]
          expect( place.lat ).to be_within(0.001).of 45.512043
          expect( place.lon ).to be_within(0.001).of -122.613144
        end

        it "truly prioritizes nearby in finding matches (e.g. St Peters Episcopal Church in Fernandina Beach FL vs. Gainsville FL)" do
          place = PlaceCompleter.new(yml_data('amelia-island', 'http://www.nytimes.com/', "St. Peter's Episcopal Church Cemetery")[:place]).complete!
          expect( place.locality ).to eq("Fernandina Beach")
          expect( place.lat ).to be_within(0.001).of(30.669427976988448)
          expect( place.lon ).to be_within(0.001).of(-81.45895476767303)
          expect( place.meta_category ).to eq "See"
          expect( place.extra ).to hash_eq(section_title: "Favorite Haunts")
          expect( place.names ).to eq ["St. Peter's Episcopal Church Cemetery", "St Peters Episcopal Church"]
        end

        it "generates full completer for O'Connell Bridge" do
          place = PlaceCompleter.new(yml_data('dublin', 'http://www.nytimes.com/', "O'Connell Bridge")[:place]).complete!
          expect( place.categories ).to eq ['Bridge', 'Monument / Landmark', 'Other Great Outdoors']
          expect( place.meta_categories ).to eq ['See', 'Do']
          expect( place.images.count ).to be >= 6
          expect( place.street_address ).to eq "Droichead Uí Chonaill"
          expect( place.full_address ).to eq "Droichead Uí Chonaill, Dublin, Ireland"
          expect( place.foursquare_id ).to eq "4afbccfef964a520181f22e3"
          expect( place.lat ).to be_within(0.04).of 53.3473244
          expect( place.lon ).to be_within(0.04).of -6.258941099999999
          expect( place.website ).to eq "http://www.bridgesofdublin.ie/bridges/oconnell-bridge"
        end

        xit "doesn't return Bogota Beer Company for Bogotá query" do
          # no idea here what the originating query/YML is?
        end

        it "prioritizes plan english names over hex/non-english names(e.g. Wagas vs 沃歌斯; in Shanghai)" do
          place = PlaceCompleter.new(yml_data('nikoklein', 'http://www.googlemaps.com/', "沃歌斯")[:place]).complete!
          expect( place.name ).to eq 'Wagas'
          expect( place.names ).to eq  ["Wagas", "沃歌斯", "Wagas | 沃歌斯"] # Converts decimal encoding to characters
          expect( place.full_address ).to eq "浦东南路999号新梅联合广场104单元, 上海市, 上海市, 中国"
          expect( place.street_addresses ).to include "999 Pudong South Road, Pudong, Shanghai, China"
          expect( place.categories ).to eq ["Cafe"]
          expect( place.meta_categories ).to eq ["Food"]
          expect( place.sublocality ).to eq "Pudong Xinqu"
          expect( place.phones ).to eq ["862151341075"]
        end

        it "combines locations that are named distinctly only by introductory article (e.g. Casa de Socorro & La Casa de Socorro)" do
          place = PlaceCompleter.new(yml_data('nikoklein', 'http://www.googlemaps.com/', "LA CASA DE SOCORRO")[:place]).complete!
          expect( place.name ).to eq('La Casa de Socorro')
          expect( place.lat ).to be_within(0.03).of 10.4202192
          expect( place.lon ).to be_within(0.03).of -75.5475489
          expect( place.website ).to eq "http://www.restaurantelacasadesocorro.com/"
          expect( place.names ).to eq ["La Casa de Socorro"]
          expect( place.phone ).to eq("5756644658")
          expect( place.categories ).to eq ["Caribbean Restaurant"]
          expect( place.meta_categories ).to eq ["Food"]
        end
      end

      context "with preexisting place in db" do
        it "finds the Trident hotel with less information, and by either name" do
          place = PlaceCompleter.new({ name: 'Trident Nariman Point', nearby: 'Bombay', street_address: 'Nariman Point, Mumbai, India'}).complete!
          place2 = PlaceCompleter.new({ name: 'Trident Nariman Point', nearby: 'Mumbai'}).complete!
          place3 = PlaceCompleter.new({ name: 'The Trident', nearby: 'Bombay', street_address: 'Nariman Point, Mumbai, India'}).complete!

          expect( place ).to eq place2
          expect( place2 ).to eq place3
        end

        it "recognizes the varying Fuunjis" do
          place = PlaceCompleter.new({ name: 'Fu-Unji', nearby: 'Shinjuku, Tokyo' }).complete!
          place2 = PlaceCompleter.new({ name: 'Fu-Unji', nearby: 'Tokyo'}).complete!
          place3 = PlaceCompleter.new({ name: 'Fuunji', nearby: 'Tokyo, Japan'}).complete!

          expect( place ).to eq place2
          expect( place2 ).to eq place3
        end

        it "skips completion if it has enough locality info to find a previous place" do
          expect_any_instance_of(PlaceCompleter).to receive(:api_complete!).once.and_call_original
          place1 = PlaceCompleter.new({ name: 'Trident Nariman Point', nearby: "Bombay", street_address: 'Nariman Point, Mumbai, India' }).complete!
          place2 = PlaceCompleter.new({ name: 'Trident Nariman Point', locality: 'Mumbai', street_address: 'Nariman Point, Mumbai, India' }).complete!

          expect( place1 ).to eq place2
        end

        xit "doesn't skip completion if there is more than one search result" do
          place1 = PlaceCompleter.new({ name: 'Starbucks', nearby: "Coal Harbor, Vancouver", street_address: '1099 Robson Street' }).complete!
          place2 = PlaceCompleter.new({ name: 'Starbucks', locality: 'Vancouver', street_address: '900 Granville St' }).complete!
          place3 = PlaceCompleter.new({ name: 'Starbucks', locality: 'Vancouver', country: 'Canada' }).complete!
          places = [place1, place2, place3]
          expect( places.map(&:locality).uniq ).to eq ['Vancouver']
          expect( places.map(&:names).uniq ).to eq [['Starbucks']]
          expect( places.map(&:country).uniq ).to eq ['Canada']
          expect( places.map(&:lat).uniq.count ).to eq 3
          expect( places.map(&:lon).max - places.map(&:lon).min ).to be < 0.01 # Stringent lat/lon comparisons
          expect( places.map(&:id).uniq.count ).to eq 3

        end

        it "finds, correctly locates, and combines various Dwelltimes" do
          place = PlaceCompleter.new({ name: "Dwelltime", nearby: 'Boston, MA'}).complete!
          place2 = PlaceCompleter.new({ name: "Dwelltime", nearby: 'Cambridge, MA' }).complete!
          place3 = PlaceCompleter.new({ name: "Dwelltime", nearby: 'Cambridge, MA', street_address: '364 Broadway'}).complete!

          place.reload; place2.reload; place3.reload 
          expect( place ).to eq place2
          expect( place2 ).to eq place3

          expect(place.locality).to eq('Cambridge')
          expect(place.region).to eq("Massachusetts")
          expect(place.street_addresses).to eq(['364 Broadway'])
          expect(place.lat).to be_within(0.00001).of 42.3705576508449
          expect(place.lon).to be_within(0.00001).of -71.1043846607208
          expect(place.category).to eq 'Coffee Shop'
          expect(place.website).to eq 'http://dwelltimecambridge.com'
          expect(place.images.first.url).to eq "https://irs3.4sqi.net/img/general/#{ApiVenue::FoursquareExploreVenue::IMAGE_SIZE}/6026_ruM6F73gjApA1zufxgbscViPgkbrP5HaYi_L8gti6hY.jpg"
        end

        it "combines locations that are named distinctly only by introductory article (e.g. Casa de Socorro & La Casa de Socorro)" do
          place1 = PlaceCompleter.new(yml_data('nikoklein', 'http://www.googlemaps.com/', "LA CASA DE SOCORRO")[:place]).complete!
          place2 = PlaceCompleter.new(yml_data('cartagena', 'http://www.huffingtonpost.com/', "Casa de Socorro")[:place]).complete!
          expect( place2.names ).to eq(['La Casa de Socorro'])
          expect( place1 ).to eq place2
        end

      end

      describe "how it cleans/flattens incoming hash info" do
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
          expect( place.names ).to eq ['Fu-Unji', 'Fuunji', '風雲児']
          expect( place.street_addresses ).to include '代々木2-14-3'
          expect( place.street_addresses ).to include "2 Chome-14 Yoyogi"
          expect( place.extra.except(:google_place_url) ).to hash_eq({ rating: 5, rating_tier: '5 star', twitter: '@fuunjiIsTheShit' })
          expect( place.foursquare_id ).to eq "4b5983faf964a520ca8a28e3"
          expect( place.completion_steps ).to array_eq ["FoursquareExplore", "GoogleMaps", "FoursquareRefine", "TranslateAndRefine"]
          expect( place.sublocality ).to eq "代々木" # Translate didn't give English Sublocality
        end
      end
    end
  end
end