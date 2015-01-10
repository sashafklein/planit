require 'spec_helper'

module Completers
  describe PlaceCompleter do 

    include ScraperHelper 

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
          expect( place.region ).to eq('Tokyo-to')
          expect( place.subregion ).to eq(nil)
          expect( place.locality ).to eq('Shibuya-ku')
          expect( place.street_addresses ).to eq( ["代々木2-14-3"] ) # Bonus -- should have "2 Chome-14 Yoyogi"
          expect( place.names ).to eq( ["Fuunji", "風雲児"] )
          expect( place.phones.symbolize_keys ).to eq({ default: "+81364138480" })
          expect( place.category ).to eq("Ramen / Noodle House")
        end

        it "locates and doesn't overwrite Cundinamarca AirBNB", :vcr do
          place = PlaceCompleter.new({ name: "Penthouse room with a view (Airbnb)", nearby: 'Bogota, Colombia', street_address: "701, 957 Calle 51", full_address: 'Calle 51 # 9-57 Apt 701, Bogota, Cundinamarca, Colombia' }).complete!
          expect( place.street_addresses ).to eq( ["701, 957 Calle 51"] )
          expect( place.names ).to eq( ["Penthouse room with a view (Airbnb)"] )
          expect( place.full_address ).to eq("Calle 51 # 9-57 Apt 701, Bogota, Cundinamarca, Colombia")
          expect( place.lat ).to be_within(0.000001).of(4.6379639)
          expect( place.lon ).to be_within(0.000001).of(-74.0648845)
        end

        it 'finds La Cevicheria in Cartagena', :vcr do
          place = PlaceCompleter.new({name: 'La Cevicheria', street_address: "Calle Stuart No 7-14", nearby: "Cartagena, Colombia"} ).complete!
          
          expect( place.locality ).to eq "Cartagena de Indias"
          expect( place.country ).to eq "Colombia"
          expect( place.region ).to eq "Bolivar"
          expect( place.category ).to eq 'Seafood Restaurant'
          expect( place.street_addresses ).to eq ["Calle Stuart No 7-14", "Calle Stuart 7-14"]
          expect( place.lat ).to eq 10.428036
          expect( place.lon ).to eq -75.548012
        end

        it "locates the Trident hotel in Mumbai, with 'Bombay' as nearby", :vcr do
          place = PlaceCompleter.new({ name: 'Trident Nariman Point', nearby: 'Bombay', street_address: 'Nariman Point, Mumbai, India'}).complete!
          expect( place.names ).to eq(["Trident Nariman Point", "The Trident"])
          expect( place.reload.phones.symbolize_keys ).to eq({ default: "+912266324343" })
          expect( place.region ).to eq("Maharashtra")
          expect( place.street_addresses ).to eq(["Nariman Point, Mumbai, India", "Nariman Point"])
          expect( place.locality ).to eq("Mumbai")
          expect( place.category ).to eq('Hotel')
          expect( place.website ).to eq("http://www.tridenthotels.com")
          expect( place.lat ).to be_within(0.01).of(18.9255728)
          expect( place.lon ).to be_within(0.01).of(72.8242221)
        end

        xit "locates Caffe Vita Inc and fills out the category" do
          place = PlaceCompleter.new(yml_data('nikoklein', 'http://www.googlemaps.com/', "Caffe Vita Inc")[:place]).complete!
          binding.pry
        end

        xit "locates Trocadero Club and fills out the category" do
          place = PlaceCompleter.new(yml_data('nikoklein', 'http://www.googlemaps.com/', "Trocadero Club")[:place]).complete!
          binding.pry
        end

        it "saves hours as a hash, accessable as a deep struct" do
          place = PlaceCompleter.new(yml_data('comptoir', 'http://www.yelp.com/biz/le-comptoir-du-relais-paris')[:place]).complete!
          expect(place.hours).to eq({
            'mon' => {"start_time" => "12:00 pm", "end_time" => "12:00 am"},
            'tue' => {"start_time" => "12:00 pm", "end_time" => "12:00 am"},
            'wed' => {"start_time" => "12:00 pm", "end_time" => "12:00 am"},
            'thu' => {"start_time" => "12:00 pm", "end_time" => "12:00 am"},
            'fri' => {"start_time" => "12:00 pm", "end_time" => "12:00 am"},
            'sat' => {"start_time" => "12:00 pm", "end_time" => "2:00 am"},
            'sun' => {"start_time" => "12:00 pm", "end_time" => "12:00 am"}
          })
          expect(place.hours_struct.mon.start_time).to eq("12:00 pm")
        end

        xit "flips L/L if needed (e.g. Gâteaux Thoumieux in Mogadishu)" do
          place = PlaceCompleter.new(yml_data('thoumieux-flipped', 'http://www.eater.com/', "Gâteaux Thoumieux")[:place]).complete!
          expect( place.lat ).to be_within(0.01).of(48.85989163257022)
          expect( place.lon ).to be_within(0.01).of(2.3091419555351185)
        end

        xit "ensures L/L exists within natural bounds (e.g. Apizza Scholls in Antartica) -- also flip" do
          place = PlaceCompleter.new(yml_data('apizza-scholls-flipped', 'http://www.eater.com/', "Apizza Scholls")[:place]).complete!
          expect( place.lat ).to be_within(0.01).of(45.512043)
          expect( place.lon ).to be_within(0.01).of(-122.613144)
        end

        xit "truly prioritizes nearby in finding matches (e.g. St Peters Episcopal Church in Fernandina Beach FL vs. Gainsville FL)" do
          place = PlaceCompleter.new(yml_data('amelia-island', 'http://www.nytimes.com/', "St. Peter's Episcopal Church Cemetery")[:place]).complete!
          expect( place.locality ).to eq("Fernandina Beach")
          expect( place.lat ).to be_within(0.01).of(30.669427976988448)
          expect( place.lon ).to be_within(0.01).of(-81.45895476767303)
        end

        xit "generates full completer for O'Connell Bridge" do
          place = PlaceCompleter.new(yml_data('dublin', 'http://www.nytimes.com/', "O'Connell Bridge")[:place]).complete!
          expect( place.categories ).to eq ['Bridge', 'Monument / Landmark', 'Other Great Outdoors']
          expect( place.image ).not_to eq nil
        end

        xit "doesn't return Bogota Beer Company for Bogotá query" do
          # no idea here what the originating query/YML is?
        end

        xit "prioritizes plan english names over hex/non-english names(e.g. Wagas vs &#27779;&#27468;&#26031; in Shanghai)" do
          place = PlaceCompleter.new(yml_data('nikoklein', 'http://www.googlemaps.com/', "&#27779;&#27468;&#26031;")[:place]).complete!
          expect( place.name ).to eq 'Wagas'
          expect( place.names ).to eq ['&#27779;&#27468;&#26031;', 'Wagas']
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
          place = PlaceCompleter.new({ name: 'Fu-Unji', nearby: 'Shinjuku, Tokyo' }).complete!
          place2 = PlaceCompleter.new({ name: 'Fu-Unji', nearby: 'Tokyo'}).complete!
          place3 = PlaceCompleter.new({ name: 'Fuunji', nearby: 'Tokyo, Japan'}).complete!

          expect( place ).to eq place2
          expect( place2 ).to eq place3
        end


        it "finds, correctly locates, and combines various Dwelltimes", :vcr do
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
          expect(place.images.first.url).to eq "https://irs3.4sqi.net/img/general/#{Completers::FourSquareVenue::IMAGE_SIZE}/6026_ruM6F73gjApA1zufxgbscViPgkbrP5HaYi_L8gti6hY.jpg"
        end

        xit "combines locations that are named distinctly only by introductory article (e.g. Casa de Socorro & La Casa de Socorro)" do
          place = PlaceCompleter.new(yml_data('nikoklein', 'http://www.googlemaps.com/', "LA CASA DE SOCORRO")[:place]).complete!
          expect( place.name ).to eq('La Casa de Socorro')
          # how do we ensure this is combined?
        end

        xit "combines locations that are named distinctly only by introductory article (e.g. Casa de Socorro & La Casa de Socorro)" do
          place = PlaceCompleter.new(yml_data('cartagena', 'http://www.huffingtonpost.com/', "Casa de Socorro")[:place]).complete!
          expect( place.name ).to eq('La Casa de Socorro')
          # how do we ensure this is combined?
        end

      end

      describe "how it cleans/flattens incoming hash info" do
        it "turns excess into 'extra', and flattens name/street_address into names/street_addresses", :vcr do
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
          expect( place.extra.symbolize_keys ).to eq({ rating: '5', rating_tier: '5 star', twitter: '@fuunjiIsTheShit', four_square_id: "4b5983faf964a520ca8a28e3", menu_url: nil, mobile_menu_url: nil })
          expect( place.completion_steps ).to eq ["Narrow", "FourSquare", "Translate"]
          expect( place.sublocality ).to eq "Yoyogi"
        end
      end

    end
  end
end