require 'rails_helper'

module Completers
  describe Completer, :vcr do

    include ScraperHelper

    describe "complete!" do

      before do 
        @user = create(:user)
      end

      context "new place" do
        context "with no sequence or plan data" do
          it "saves and returns an associated mark, rounded out by Geocoder and Foursquare API" do
            c = Completer.new(place_hash, @user)
            mark = c.complete!

            expect(mark.user).to eq @user
            
            place = mark.place
            expect(place.name).to eq place_hash[:place][:names][0]
            expect(place.street_address).to eq place_hash[:place][:street_addresses].first
            expect(place.locality).to eq "Cartagena de Indias"
            expect(place.country).to eq place_hash[:place][:country]
            expect(place.foursquare_id).to be_present
            expect(place.categories).to include "Ice Cream Shop"
            expect(place.meta_category).to eq "Food"
          end

          it "grabs more info from FoursquareExplore" do
            expect( Image.count ).to eq 0
            c = Completer.new(place_hash, @user)
            mark = c.complete!

            expect(mark.place.images.first).to be_present
          end

          it "ignores but retains unusable data" do
            c = Completer.new(place_hash({made_up: 'whatever'}), @user)
            c.complete!
            expect(c.decremented_attrs).to eq({ made_up: 'whatever'})
          end

          it "uses scraped images and Foursquare images" do
            c = Completer.new(YAML.load_file( File.join(Rails.root, 'spec', 'support', 'pages', 'tripadvisor', 'fuunji.yml')).first, @user)
            m = c.complete!
            p = m.place

            expect(p.images.count).to be > 3
            expect(p.images.where(source: 'Trip Advisor').count).to eq 4
          end

        end  
      end

      context "with a preexisting mark" do
        before do 
          @user = create(:user)
          @place = Place.create!(place_hash[:place])
          @mark = Mark.create!(user: @user, place: @place)
        end

        it "finds the mark, and doesn't create duplicates" do
          mark_count = Mark.count
          place_count = Place.count
          c = Completer.new(place_hash, @user)

          completed_mark = c.complete!
          expect(Mark.count).to eq(mark_count)
          expect(Place.count).to eq(place_count)

          expect(completed_mark).to eq @mark
        end

        it "fills any missing info" do
          atts = place_hash({}, {random_other: 'value'})
          completed_mark = Completer.new(atts, @user).complete!

          expect( @mark.reload.place.extra.slice(:random_other) ).to hash_eq({random_other: 'value'})
          expect( @mark.place.foursquare_id ).to eq "509ef2b9e4b01b9e49f1d25c"
        end
      end

      context "with sequence data" do
        context "without legs" do
          it "creates an item, associated with day and plan" do
            expect(Item.count).to eq(0)

            m = Completer.new(place_hash(sequence_hash), @user).complete!
            item = m.items.first

            expect(item.plan.name).to eq sequence_hash[:plan][:name]
            expect(item.plan.source.name).to eq "New York Times"
            expect(item.order).to eq(1)
            expect(item.start_time).to eq('0300')
            expect(item.duration).to eq(0.5)
            expect(item.weekday).to eq('Friday')
            expect(item.day.order).to eq(1)
            expect(item.leg).to be_present # Creates a blank leg inside the plan
            expect( m.source.name ).to eq 'New York Times'
            expect( m.source.trimmed_url ).to eq "http://www.nytimes.com/2014/09/14/travel/things-to-do-in-36-hours-in-cartagena-colombia.html"
            expect( m.source.full_url ).to eq "http://www.nytimes.com/2014/09/14/travel/things-to-do-in-36-hours-in-cartagena-colombia.html?_r=0"
          end
        end
      end

      context "item data outside a plan context" do
        context "without good api data" do
          it "creates the place, mark, plan, and location" do
            m = completed_data(filename: 'itinerary', scrape_url: 'https://www.airbnb.com/reservation/itinerary?code=ZBCAT4', name: nil)

            expect( m.country ).to eq("Colombia")
            expect( m.locality ).to eq("Bogota")

            i = m.items.first

            expect(i.extra).to hash_eq({ 
              guests: "2", 
              nights: "3", 
              host_directions: "Host's Directions The apt its located in an area called \"chapinero\" which is a central place of the city helping you get easily to any destination",
              confirmation_url: "https://www.airbnb.com/reservation/itinerary?code=ZBCAT4",
              cost: "$157",
              confirmation_code: "ZBCAT4",
              start_date: "Fri, November 21, 2014",
              end_date: "Mon, November 24, 2014"
            })

            expect( m.source.name ).to eq 'AirBNB'
            expect( m.source.trimmed_url ).to eq "https://www.airbnb.com/reservation/itinerary?code=ZBCAT4"
          end
        end

        context "tricky Google one" do
          it "gets it too" do
            m = completed_data(filename: 'nikoklein', scrape_url: 'http://www.googlemaps.com/', name: 'Restaurante Los Almendros')
            f = m.place.flags.states
            expect(m.country).to eq "Colombia"
            expect(m.region).to eq "Magdalena"
            expect( m.source.name ).to eq 'Google Maps'
          end
        end
      end

      context "item data with plan" do
        it "creates the Coney Island, and fits it in context" do
          m = completed_data(filename: 'nyhigh', scrape_url: 'http://www.stay.com/new-york/', name: 'Coney Island')
          p = m.place

          expect( p.country ).to eq "United States"
          expect( p.region ).to eq "New York"

          expect( p.extra['ratings'] ).to be_present

          expect( p.sublocality ).to eq("Brooklyn")
          expect( p.categories ).to eq ["Attraction", "Beach", "Theme Park"]
          i = m.items.first
          expect( i.plan.name ).to eq "New York City Guide"

          expect( m.source.name ).to eq "Stay"
        end

        it "creates the Plaza in context" do
          m = completed_data(filename: 'jetsetters', scrape_url: 'http://www.stay.com/new-york/guides/296846-dbc0095d/new-york-for-jetsetters/', name: 'The Plaza')

          expect(m.country).to eq "United States"
          expect(m.region).to eq "New York"
          expect(m.locality).to eq "New York"
          
          p = m.place
          expect(m.place.sublocality).to eq "Manhattan"

          i = m.items.first
          expect(i.plan.name).to eq "New York for Jetsetters"
          expect( m.source.name ).to eq "Stay"
        end

        xit "creates Boom Boom Room in context despite crappy FS data" do
          m = completed_data( filename: 'jetsetters', scrape_url: 'http://www.stay.com/new-york/guides/296846-dbc0095d/new-york-for-jetsetters/', name: 'Boom Boom Room' )

          expect(m.country).to eq "United States"
          expect(m.region).to eq "New York"
          expect(m.locality).to eq "New York"
          expect(m.place.completion_steps).to eq ["Pin"]

          i = m.items.first
          expect(i.plan.name).to eq "New York for Jetsetters"
          expect( m.source.name ).to eq "Stay"
        end

        it "creates Broadway in context" do
          m = completed_data( filename: 'nyhigh', scrape_url: 'http://www.stay.com/new-york/', name: 'Broadway' )

          expect(m.country).to eq "United States"
          expect(m.region).to eq "New York"
          expect(m.locality).to eq "New York"
          expect(m.name).to eq "Broadway"
          i = m.items.first
          expect(i.plan.name).to eq "New York City Guide"
          expect( m.source.name ).to eq "Stay"
        end

        it "creates Tribute WTC Visitor Center in context" do
          m = completed_data( filename: 'nyhigh', scrape_url: 'http://www.stay.com/new-york/', name: 'Tribute WTC Visitor Center')

          expect(m.country).to eq "United States"
          expect(m.region).to eq "New York"
          expect(m.locality).to eq "New York"
          expect(m.name).to eq "Tribute WTC Visitor Center"
          i = m.items.first
          expect(i.plan.name).to eq "New York City Guide"
          expect(m.place.scrape_url).to eq 'http://www.stay.com/new-york/'
          expect( m.source.name ).to eq "Stay"
        end
      end

      describe "failed seeds" do

        describe "finds only options" do
          it 'suggests good options for Alma from HuffPo' do
            m = completed_data(filename: 'cartagena', scrape_url: "http://www.huffingtonpost.com/curtis-ellis/cartagena-eat-pray-love-d_b_3479981.html", name: 'Alma')
            expect( m.place ).to be_nil
            expect( m.place_options.count ).to be > 1

            option = m.place_options.with_name("Restaurante Alma").first
            expect( option ).to be_a PlaceOption
            expect( option.foursquare_id ).to be_present
            attrflag = m.flags.find_by(name: 'Original Attrs')
            expect( attrflag.info.nearby ).to eq 'Cartagena, Colombia'
            expect( attrflag.info.names.first ).to eq 'Alma'
          end

          it 'suggests good options for Alma from NYTimes' do
            m = completed_data(filename: 'cartagena', scrape_url: "http://www.huffingtonpost.com/curtis-ellis/cartagena-eat-pray-love-d_b_3479981.html", name: 'Alma')
            expect( m.place ).to be_nil
            expect( m.place_options.count ).to be > 1

            option = m.place_options.with_name("Restaurante Alma").first
            expect( option ).to be_a PlaceOption
            expect( option.foursquare_id ).to be_present
          end

          # Neither Foursquare nor Google finds anything that looks good
          it "rejects Palma Cartagena" do
            m = completed_data(filename: 'foodies', scrape_url: "http://www.nytimes.com/2008/10/26/travel/26choice.html?pagewanted=all&_r=0", name: "Palma")
            expect( m.place_options.count ).to be > 0

            option = m.place_options.with_name("Las Palmas").first
            expect( option ).to be_a PlaceOption
            place = option.choose!
            expect( place.locality ).to eq 'Cartagena De Indias'
          end
        end
        
        describe "still failing" do

          xit "correctly pins Amelia Toro" do
            # https://www.google.com/webhp?sourceid=chrome-instant&ion=1&espv=2&ie=UTF-8#q=amelia%20toro%20bogota
          end

          xit "rejects Xoco Chocolate? or Correctly Pins?" do
            # incorrectly placed on the map... 3 chain branches in bogota, offer all as options?
            # maybe this https://foursquare.com/v/xoco/4d839967509137049b9f6c5b
            # use verification and "usersCount" to invalidate? + no images? <50 users, <5 images
            # "verified"=>false, / "stats"=>{"checkinsCount"=>4273, "usersCount"=>3783, "tipCount"=>125},
          end

          xit "correctly locates Villa De Leyva NOT in Bogota" do
            m = completed_data(filename: 'leyva', scrape_url: "http://www.frommers.com/destinations/bogota/278016", name: "Villa de Leyva")
            # Villa De Leyva
          end

          # Requires alternatives -- Isn't triangulating perfectly
          xit "correctly locates Hospedería Duruelo NOT in Bogota" do
            m = completed_data(filename: 'leyva', scrape_url: "http://www.frommers.com/destinations/bogota/278016", name: "Hospedería Duruelo")
            p = m.place
            # See https://www.google.com/maps/place/Hotel+el+Duruelo/@5.628924,-73.517965,14z/data=!4m2!3m1!1s0x8e41d708ca5087e9:0xaca8b4ef69ec38e6
          end

          # Google has it, with no notes about its being closed -- not sure what to do about this one
          xit "doesn't find The Down Under (but shows options)" do
            m = completed_data(filename: 'amelia-island', scrape_url: "http://www.nytimes.com/2003/12/12/travel/journeys-36-hours-amelia-island-fla.html?pagewanted=all", name: "The Down Under")
          end

          xit "completes Tayrona from Mauricio.yml" do
            m = completed_data(filename: 'mauricio', scrape_url: "http://www.email.com/", name: 'Tayrona')
            # There's just too little info in the @yml
            # Select Parque Tayrona b/c of photos and frequency of visits https://foursquare.com/v/parque-nacional-natural-tayrona/4e9dd4b261af4feab6578266
          end

          # It doesn't find it. I think that's fine, given the shitty information. People can add manually, as part of the alternatives process
          xit "correctly locates Fatehpur Sikri outside of Delhi and not in Agra" do
            m = completed_data(filename: 'india', scrape_url: "http://www.nytimes.com/2012/03/25/travel/through-indias-desert-cities-three-itineraries.html?pagewanted=all&_r=0", name: "Fatehpur Sikri")
            p = m.place
          end

          # Again, doesn't find it at all
          xit "doesn't put Fatehpur Sikri on the highway to Fatehpur Sikri" do
            m = completed_data(filename: 'india', scrape_url: "http://www.nytimes.com/2012/03/25/travel/through-indias-desert-cities-three-itineraries.html?pagewanted=all&_r=0", name: "Fatehpur Sikri")
            p = m.place
            # What happens if we hit Foursquare API after Google?
          end

          xit "correctly identifies the most prominent Gem Palace and locates" do
            # Gem Palace and not the Jewelry store?
          end

        end

        describe "hiding private places" do
          it "marks an AirBNB place as private" do
            m = completed_data(filename: 'reservation', scrape_url: "https://www.airbnb.com/reservation/itinerary?code=ZBCAT4")

            p = m.place
            expect( p.published ).to eq false
          end
        end

        describe "fixed" do

          it "completes Yelp's Inn At Little Washington" do
            m = completed_data(filename: 'inn_at_little_washington', scrape_url: 'http://www.yelp.com/biz/the-inn-at-little-washington-washington')
            expect( m.place.name ).to eq 'The Inn at Little Washington'
            expect( m.place.phones ).to eq ["5406753800"]
            expect( m.place.categories ).to include "Bed & Breakfast"
          end
          
          it "gets Da Teo off the Frommers Rome restaurant list" do
            url = "http://www.frommers.com/destinations/rome/restaurants"
            yamlator = HtmlToYaml.new( end_path: 'frommers/restaurantlist', url: url)
            m = Completer.new(yamlator.find(name: 'Da Teo'), @user).complete!
            expect( m.place.names ).to include 'Trattoria Da TEO'
          end

          it "gets Da Remo off the Frommers Rome restaurant list" do
            url = "http://www.frommers.com/destinations/rome/restaurants"
            yamlator = HtmlToYaml.new( end_path: 'frommers/restaurantlist', url: url)
            m = Completer.new(yamlator.find(name: 'Da Remo'), @user).complete!
            expect( m.place.names ).to eq ["Da Remo", "Remo"]
            expect( m.place.categories ).to eq ["Pizza Place"]
          end

          it 'finds Simply Fresh Laundry in Denpasar' do
            url = "http://www.googlemaps.com/"
            yamlator = HtmlToYaml.new( end_path: 'googlemaps/nikoklein', url: url)
            m = Completer.new(yamlator.find(name: 'Simply Fresh Laundry'), @user).complete!            
            expect( m.place.locality ).to eq 'Kota Denpasar'
            expect( m.place.category ).to eq 'Laundry Service'
          end

          it "gets The Ritz-Carlton, Kapalua" do
            m = completed_data(filename: 'nikoklein', scrape_url: 'googlemaps', name: 'The Ritz-Carlton, Kapalua')
            p = m.place
            expect( p.street_address ).to eq '1 Ritz Carlton Drive'
            expect( p.region ).to eq 'Hawaii'
            expect( p.locality ).to eq "Kapalua"
          end

          it "gets Matsumoto Station" do
            m = completed_data(filename: 'japan', scrape_url: 'kml', name: 'matsumoto station')
            expect( m.place.categories ).to include "Train Station"
            expect( m.place.region ).to include "Nagano"
          end

          it "gets Kamakura Temples" do
            m = completed_data(filename: 'japan', scrape_url: 'kml', name: 'kamakura temples')
            expect( m.place.categories ).to include "Buddhist Temple"
            expect( m.place.region ).to include "Kanagawa"
          end

          it "saves Edinburgh, UK" do
            m = completed_data(filename: 'travelmap', scrape_url: 'http://www.tripadvisor.com', name: 'Edinburgh, UK')
            p = m.place
            expect( p.feature_type ).to eq 'locality'
            expect( p.country ).to eq 'United Kingdom'
            # expect( p.region ).to eq 'Scotland'
          end

          it "completes Quiebra-Canto" do
            m = completed_data(filename: 'cartagena', scrape_url: "http://www.nytimes.com/2014/09/14/travel/things-to-do-in-36-hours-in-cartagena-colombia.html?_r=0", name: "Quiebra-Canto")
            expect( m.source.name ).to eq "New York Times"
            expect( m.source.trimmed_url ).to eq "http://www.nytimes.com/2014/09/14/travel/things-to-do-in-36-hours-in-cartagena-colombia.html"

            p = m.place
            expect( p.lat ).to float_eq 10.421883
            expect( p.lon ).to float_eq -75.547621
            expect( p.published ).to eq true
          end

          it "completes La Mulata and El Mesón de María y Mulata" do
            m = completed_data(filename: 'cartagena', scrape_url: "http://www.nytimes.com/2014/09/14/travel/things-to-do-in-36-hours-in-cartagena-colombia.html?_r=0", name: "El Mesón de María y Mulata")
            expect( m.source.name ).to eq 'New York Times'

            p = m.place
            expect( p.lat ).to float_eq 10.419666
            expect( p.lon ).to float_eq -75.54787
            expect( p.locality ).to eq 'Cartagena De Indias'
            expect( p.published ).to eq true
          end

          # Doesn't take Google cause of the language disagreement
          it "completes Cartagena Kitesurf School" do
            m = completed_data(filename: 'cartagena', scrape_url: "http://www.nytimes.com/2014/09/14/travel/things-to-do-in-36-hours-in-cartagena-colombia.html?_r=0", name: "Cartagena Kitesurf School")
            expect( m.source.name ).to eq 'New York Times'
            
            p = m.place
            expect( p.lat ).to float_eq 10.4042588
            expect( p.lon ).to float_eq -75.4689454
            expect( p.tz ).to eq 'America/Bogota'
            expect( p.published ).to eq true
          end

          it "completes Bogotá Bike Tours" do
            m = completed_data(filename: 'bogota', scrape_url: "http://www.nytimes.com/2010/07/04/travel/04hours.html?pagewanted=all&_r=0", name: "Bogotá Bike Tours")
            expect( m.source.name ).to eq 'New York Times'

            p = m.place
            expect( p.street_address ).to eq "Carrera 3 No. 12-72"
            expect( p.lat ).to float_eq 4.5973219379763
            expect( p.lon ).to float_eq -74.0708756446838
            expect( p.sublocality ).to eq "La Candelaria"
            expect( p.published ).to eq true
          end

          it "completes La Opera (HOTEL)" do
            m = completed_data(filename: 'bogota', scrape_url: "http://www.nytimes.com/2010/07/04/travel/04hours.html?pagewanted=all&_r=0", name: "La Opera")
            expect( m.source.name ).to eq 'New York Times'

            p = m.place
            expect( p.names ).to include("Hotel de la Opera")
            expect( p.lat ).to float_eq 4.597374
            expect( p.lon ).to float_eq -74.075269
            expect( p.category ).to eq 'Hotel'
            expect( p.meta_category ).to eq 'Stay'
            expect( p.published ).to eq true
          end

          it "completes Gold Museum" do
            m = completed_data(filename: 'bogota', scrape_url: "http://www.nytimes.com/2010/07/04/travel/04hours.html?pagewanted=all&_r=0", name: "Gold Museum")
            expect( m.source.name ).to eq 'New York Times'

            p = m.place
            expect( p.names ).to include "Museo del Oro del Banco de la República"
            expect( p.lat ).to float_eq 4.601646
            expect( p.lon ).to float_eq -74.071975
            expect( p.published ).to eq true
          end

          it "correctly locates Jardin Botanico Jose Celestino Mutis" do
            m = completed_data(filename: 'bogota', scrape_url: "http://www.nytimes.com/2010/07/04/travel/04hours.html?pagewanted=all&_r=0", name: "Jardín Botánico José Celestino Mutis")
            expect( m.source.name ).to eq 'New York Times'

            p = m.place
            expect( p.lat ).to float_eq 4.669729462430818
            expect( p.lon ).to float_eq -74.09898519515991
            expect( p.sublocality ).to eq "Engativá"
            expect( p.categories ).to array_eq ["Botanical Garden", "Garden"]
            expect( p.published ).to eq true
          end

          it "correctly locates Botero Museum" do
            m = completed_data(filename: 'bogota', scrape_url: "http://www.nytimes.com/2010/07/04/travel/04hours.html?pagewanted=all&_r=0", name: "Botero Museum")
            expect( m.source.name ).to eq 'New York Times'

            p = m.place
            expect( p.phones ).to eq ["5713431212","5712845335"] # Combines identical, but differently formatted phones from Foursquare and Scraper
            expect( p.lat ).to float_eq 4.596761
            expect( p.lon ).to float_eq -74.073145
            expect( p.sublocality ).to eq 'La Candelaria'
            expect( p.hours ).to be_present
            expect( p.website ).to eq "http://www.banrepcultural.org/museo-botero"
            expect( p.names ).to eq ["Botero Museum", "Café La Manzana (great Coffee Shop) Inside BOTERO Museum", "Donación Botero"]
            expect( p.published ).to eq true
          end

          it "correctly locates Biblioteca Luis Ángel Arango" do
            m = completed_data(filename: 'bogota', scrape_url: "http://www.nytimes.com/2010/07/04/travel/04hours.html?pagewanted=all&_r=0", name: "Biblioteca Luis Ángel Arango")
            expect( m.source.name ).to eq 'New York Times'

            p = m.place
            expect( p.lat ).to float_eq 4.59702249702672
            expect( p.lon ).to float_eq -74.072892665863
            expect( p.category ).to eq 'Library'
            expect( p.website ).to eq "http://www.lablaa.org"
          end

          it "correctly locates Bite Into Maine" do
            m = completed_data(filename: 'maine', scrape_url: "kml", name: "Bite into Maine")

            expect( m.source.name ).to eq 'KML'
            expect( m.source.trimmed_url ).to eq 'KML'
            expect( m.source.full_url ).to eq 'KML'
            expect( m.source.base_url ).to eq 'KML'

            p = m.place
            expect( p.lat ).to float_eq 43.62390
            expect( p.lon ).to float_eq -70.211276
            expect( p.street_addresses ).to eq ["Fort Williams Park", "1000 Shore Road"]
            expect( p.hours ).to be_present
            expect( p.categories ).to eq ['Food Truck']
          end

          it "correctly locates Central Park in Amelia Island vicinity" do
            m = completed_data(filename: 'amelia-island', scrape_url: "http://www.nytimes.com/2003/12/12/travel/journeys-36-hours-amelia-island-fla.html?pagewanted=all", name: "Central Park")
            expect( m.source.name ).to eq 'New York Times'

            p = m.place
            expect( p.lat ).to float_eq 30.6696420369693
            expect( p.lon ).to float_eq -81.4547821101539
            expect( p.locality ).to eq "Fernandina Beach"
            expect( p.category ).to eq "Park"
          end

          it "saves Marrakech, Morocco as city not bar" do
            m = completed_data(filename: 'travelmap', scrape_url: "http://www.tripadvisor.com/TravelMapHome", name: "Marrakech, Morocco")
            expect( m.source.name ).to eq 'Trip Advisor'

            p = m.place
            expect( p.feature_type ).to eq 'locality'
            expect( p.name ).to eq 'Marrakech, Morocco' 
            expect( p.locality ).to eq 'Marrakesh' # Spelling corrected
            expect( p.lat ).to float_eq 31.632172
            expect( p.lon ).to float_eq -8.002955
            expect( p.street_address ).to be_nil
          end

          it "saves La Cocina de Pepina in Cartagena COLOMBIA" do
            m = completed_data(filename: 'cartagena', scrape_url: "http://www.nytimes.com/2014/09/14/travel/things-to-do-in-36-hours-in-cartagena-colombia.html?_r=0", name: "La Cocina de Pepina")
            expect( m.source.name ).to eq 'New York Times'

            p = m.place
            expect( p.feature_type ).to eq 'destination'
            expect( p.country ).to eq 'Colombia'
            expect( p.lat ).to float_eq 10.419546077620
            expect( p.lon ).to float_eq -75.5473468872515
            expect( p.sublocality ).to eq 'Getsemaní'
          end
        end
      end
    end

    def place_hash(overwrite_hash={}, place_additions={})
      {
        place: {
          names: ["La Paletteria"],
          street_addresses: ["Calle Santo Domingo, No. 3-88"],
          locality: "Cartagena",
          country: "Colombia", 
          lat: 10.424192,
          lon: -75.551192,
          timezone_string: 'whatever'
        }.merge(place_additions).compact
      }.merge(overwrite_hash).compact
    end

    def sequence_hash
      {
        item: {
          start_time: '3:00',
          duration: 0.5,
          order: 1,
          day_of_week: 'FRIDAY'
        },
        day: { order: 1 },
        plan: { name: "36 Hours in Cartagena, Colombia - NYTimes.com" },
        scraper_url: "http://www.nytimes.com/2014/09/14/travel/things-to-do-in-36-hours-in-cartagena-colombia.html?_r=0"
      }
    end
  end
end