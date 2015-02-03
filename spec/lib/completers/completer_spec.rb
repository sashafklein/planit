require 'spec_helper'
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
            expect(place.locality).to eq place_hash[:place][:locality]
            expect(place.country).to eq place_hash[:place][:country]
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
          @place = Place.create(place_hash[:place])
          @mark = Mark.create(user: @user, place: @place)
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
          expect( @mark.reload.place.extra ).to hash_eq({random_other: 'value'})
          expect( @mark.place.foursquare_id ).to eq "509ef2b9e4b01b9e49f1d25c"
        end
      end

      context "with sequence data" do
        context "without legs" do
          it "creates an item, associated with day and plan" do
            expect(Item.count).to eq(0)

            c = Completer.new(place_hash(sequence_hash), @user).complete!
            item = c.items.first

            expect(item.plan.name).to eq sequence_hash[:plan][:name]
            expect(item.order).to eq(1)
            expect(item.start_time).to eq('0300')
            expect(item.duration).to eq(0.5)
            expect(item.weekday).to eq('Friday')
            expect(item.day.order).to eq(1)
            expect(item.leg).to be_present # Creates a blank leg inside the plan
          end
        end
      end

      context "item data outside a plan context" do
        context "without good api data" do
          it "creates the place, mark, plan, and location" do
            c = Completer.new(yml_data('itinerary', 'https://www.airbnb.com/reservation/itinerary?code=ZBCAT4') , @user)
            m = c.complete!

            expect( m.country ).to eq("Colombia")
            expect( m.locality ).to eq("Bogota")

            i = m.items.first

            expect(i.extra).to eq({ 
              guests: "2", 
              nights: "3", 
              host_directions: "Host's Directions The apt its located in an area called \"chapinero\" which is a central place of the city helping you get easily to any destination",
              confirmation_url: "https://www.airbnb.com/reservation/itinerary?code=ZBCAT4",
              cost: "$157",
              confirmation_code: "ZBCAT4",
              start_date: "Fri, November 21, 2014",
              end_date: "Mon, November 24, 2014"
            }.stringify_keys)
          end
        end

        context "tricky Google one" do
          it "gets it too" do
            m = Completer.new(yml_data('nikoklein', 'http://www.googlemaps.com/', "Restaurante Los Almendros"), @user).complete!
            binding.pry
            expect(m.country).to eq "Colombia"
            expect(m.region).to eq "Magdalena"
          end
        end
      end

      context "item data with plan" do
        it "creates the Coney Island, and fits it in context" do
          m = Completer.new(yml_data('nyhigh', 'http://www.stay.com/new-york/', 'Coney Island'), @user).complete!

          expect( m.country ).to eq "United States"
          expect( m.region ).to eq "New York"

          expect( m.place.extra['ratings'] ).to be_present
          expect( m.place.sublocality ).to eq("Brooklyn") # No Locality for Coney Island in Geocoder
          expect( m.place.flags.find_by(name: "Field Clash").info ).to hash_eq( {"field"=>"categories", "place"=>["Attraction"], "venue"=>["Museum", "Performing Arts Venue", "General Entertainment"]} )

          i = m.items.first
          expect( i.plan.name ).to eq "New York City Guide"
        end

        it "creates the Plaza in context" do
          m = Completer.new(yml_data('jetsetters', 'http://www.stay.com/new-york/guides/296846-dbc0095d/new-york-for-jetsetters/', 'The Plaza'), @user).complete!

          expect(m.country).to eq "United States"
          expect(m.region).to eq "New York"
          expect(m.locality).to eq "New York"
          
          p = m.place
          expect(m.place.sublocality).to eq "Manhattan"

          i = m.items.first
          expect(i.plan.name).to eq "New York for Jetsetters"
        end

        it "creates Boom Boom Room in context despite crappy FS data" do
          m = Completer.new(yml_data('jetsetters', 'http://www.stay.com/new-york/guides/296846-dbc0095d/new-york-for-jetsetters/', 'Boom Boom Room'), @user).complete!

          expect(m.country).to eq "United States"
          expect(m.region).to eq "New York"
          expect(m.locality).to eq "New York"
          expect(m.place.completion_steps).to eq ["Narrow", "Translate"]

          i = m.items.first
          expect(i.plan.name).to eq "New York for Jetsetters"
        end

        it "creates Broadway in context" do
          m = Completer.new(yml_data('nyhigh', 'http://www.stay.com/new-york/', 'Broadway'), @user).complete!

          expect(m.country).to eq "United States"
          expect(m.region).to eq "New York"
          expect(m.locality).to eq "New York"
          expect(m.name).to eq "Broadway"
          i = m.items.first
          expect(i.plan.name).to eq "New York City Guide"
        end

        it "creates Tribute WTC Visitor Center in context" do
          url = 'http://www.stay.com/new-york/'
          m = Completer.new(yml_data('nyhigh', url, 'Tribute WTC Visitor Center'), @user, url).complete!

          expect(m.country).to eq "United States"
          expect(m.region).to eq "New York"
          expect(m.locality).to eq "New York"
          expect(m.name).to eq "Tribute WTC Visitor Center"
          i = m.items.first
          expect(i.plan.name).to eq "New York City Guide"
          expect(m.place.scrape_url).to eq 'http://www.stay.com/new-york/'
        end
      end

      describe "failed seeds" do

        xit 'completes Alma' do
          p = completed_data(filename: 'cartagena', scrape_url: "http://www.huffingtonpost.com/curtis-ellis/cartagena-eat-pray-love-d_b_3479981.html", name: 'Alma')
          # Finds Alma in Casa San Agustin https://foursquare.com/v/restaurante-alma/50d11a74e4b00e3143cbf000
        end

        xit "completes Tayrona from Mauricio.yml" do
          c = completed_data(filename: 'mauricio', scrape_url: "http://www.email.com/", name: 'Tayrona')
          m = c.complete!
          # Select Parque Tayrona b/c of photos and frequency of visits https://foursquare.com/v/parque-nacional-natural-tayrona/4e9dd4b261af4feab6578266
        end

        xit "completes Quiebra-Canto" do
          c = completed_data(filename: 'cartagena', scrape_url: "http://www.nytimes.com/2014/09/14/travel/things-to-do-in-36-hours-in-cartagena-colombia.html?_r=0", name: "Quiebra-Canto")
          m = c.complete!
          # Select Quiebracanto b/c of photos and frequency of visits (168 vs 30) https://foursquare.com/v/quiebracanto/4c37db551e06d13a8cd2763e
        end

        xit "completes La Mulata and El Mesón de María y Mulata" do
          c = completed_data(filename: 'cartagena', scrape_url: "http://www.nytimes.com/2014/09/14/travel/things-to-do-in-36-hours-in-cartagena-colombia.html?_r=0", name: "El Mesón de María y Mulata")
          m = c.complete!
          # Select nearby Restaurante La Mulata b/c of photos and frequency of visits (612 vs 13) https://foursquare.com/v/restaurante-la-mulata/4ced55575de16ea84f82b596
        end

        xit "rejects Palma Cartagena" do
          c = completed_data(filename: 'foodies', scrape_url: "http://www.nytimes.com/2008/10/26/travel/26choice.html?pagewanted=all&_r=0", name: "Palma")
          m = c.complete!
          # Unsatisfactory results, all in Italy??
        end

        xit "completes Cartagena Kitesurf School" do
          c = completed_data(filename: 'cartagena', scrape_url: "http://www.nytimes.com/2014/09/14/travel/things-to-do-in-36-hours-in-cartagena-colombia.html?_r=0", name: "Cartagena Kitesurf School")
          m = c.complete!
          # No Foursquare Results with Kitesurf in them, so...?
          # Maybe scrape the website we have since we have one? http://kitesurfcartagena.com/contacts/ 
        end
        
        xit 'completes Alma' do
          c = completed_data(filename: 'cartagena', scrape_url: "http://www.huffingtonpost.com/curtis-ellis/cartagena-eat-pray-love-d_b_3479981.html", name: 'Alma')
          m = c.complete!
          # binding.pry
        end

        xit "completes Tayrona from Mauricio.yml" do
          c = completed_data(filename: 'mauricio', scrape_url: "http://www.email.com/", name: 'Tayrona')
          m = c.complete!
          binding.pry
          # Select Parque Tayrona b/c of photos and frequency of visits https://foursquare.com/v/parque-nacional-natural-tayrona/4e9dd4b261af4feab6578266
        end

        xit "completes Bogotá Bike Tours" do
          c = completed_data(filename: 'bogota', scrape_url: "http://www.nytimes.com/2010/07/04/travel/04hours.html?pagewanted=all&_r=0", name: "Bogotá Bike Tours")
          m = c.complete!
          # Correct downtown location
        end

        xit "completes La Opera (HOTEL)" do
          c = completed_data(filename: 'bogota', scrape_url: "http://www.nytimes.com/2010/07/04/travel/04hours.html?pagewanted=all&_r=0", name: "La Opera")
          m = c.complete!
          # Foursquare result of "Hotel de la Opera" with StreetName closeness? "Calle 10 (5-72 La Candelaria)" to "Calle 10 No. 5-72"
        end

        xit "completes Gold Museum" do
          c = completed_data(filename: 'bogota', scrape_url: "http://www.nytimes.com/2010/07/04/travel/04hours.html?pagewanted=all&_r=0", name: "Gold Museum")
          m = c.complete!
          # Museo del Oro del Banco de la República is the right answer (4c7ab97e278eb713a3635b80), but wrong language
        end

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
          c = completed_data(filename: 'leyva', scrape_url: "http://www.frommers.com/destinations/bogota/278016", name: "Villa de Leyva")
          m = c.complete!
          # Villa De Leyva
        end

        xit "correctly locates Jardin Botanico Jose Celestino Mutis" do
          c = completed_data(filename: 'bogota', scrape_url: "http://www.nytimes.com/2010/07/04/travel/04hours.html?pagewanted=all&_r=0", name: "Jardín Botánico José Celestino Mutis")
          m = c.complete!
          # Comes from NYTimes, even if we have via TripAdvisor, not merging? Also way off?
        end

        xit "correctly locates Botero Museum" do
          c = completed_data(filename: 'bogota', scrape_url: "http://www.nytimes.com/2010/07/04/travel/04hours.html?pagewanted=all&_r=0", name: "Botero Museum")
          m = c.complete!
        end

        xit "correctly locates Biblioteca Luis Ángel Arango" do
          c = completed_data(filename: 'bogota', scrape_url: "http://www.nytimes.com/2010/07/04/travel/04hours.html?pagewanted=all&_r=0", name: "Biblioteca Luis Ángel Arango")
          m = c.complete!
        end

        xit "correctly locates Jardin Botanico Jose Celestino Mutis" do
          c = completed_data(filename: 'bogota', scrape_url: "http://www.nytimes.com/2010/07/04/travel/04hours.html?pagewanted=all&_r=0", name: "Jardín Botánico José Celestino Mutis")
          m = c.complete!
          # See https://www.google.com/maps/place/Hotel+el+Duruelo/@5.628924,-73.517965,14z/data=!4m2!3m1!1s0x8e41d708ca5087e9:0xaca8b4ef69ec38e6
        end

        xit "correctly locates Bite Into Maine" do
          c = completed_data(filename: 'bogota', scrape_url: "http://www.nytimes.com/2010/07/04/travel/04hours.html?pagewanted=all&_r=0", name: "Bite Into Maine")
          m = c.complete!
        end

        xit "correctly locates Hospedería Duruelo NOT in Bogota" do
          c = completed_data(filename: 'leyva', scrape_url: "http://www.frommers.com/destinations/bogota/278016", name: "Hospedería Duruelo")
          m = c.complete!
          # See https://www.google.com/maps/place/Hotel+el+Duruelo/@5.628924,-73.517965,14z/data=!4m2!3m1!1s0x8e41d708ca5087e9:0xaca8b4ef69ec38e6
        end

        xit "rejects The Down Under" do
          c = completed_data(filename: 'amelia-island', scrape_url: "http://www.nytimes.com/2003/12/12/travel/journeys-36-hours-amelia-island-fla.html?pagewanted=all", name: "The Down Under")
          m = c.complete!
          # 
        end

        xit "correctly locates Central Park in Amelia Island vicinity" do
          c = completed_data(filename: 'amelia-island', scrape_url: "http://www.nytimes.com/2003/12/12/travel/journeys-36-hours-amelia-island-fla.html?pagewanted=all", name: "Central Park")
          m = c.complete!
          # 
        end

        xit "correctly locates Fatehpur Sikri outside of Delhi and not in Agra" do
          c = completed_data(filename: 'india', scrape_url: "http://www.nytimes.com/2012/03/25/travel/through-indias-desert-cities-three-itineraries.html?pagewanted=all&_r=0", name: "Fatehpur Sikri")
          m = c.complete!
          # What happens if we hit Foursquare API after Google?
        end

        xit "doesn't put Fatehpur Sikri on the highway to Fatehpur Sikri" do
          c = completed_data(filename: 'india', scrape_url: "http://www.nytimes.com/2012/03/25/travel/through-indias-desert-cities-three-itineraries.html?pagewanted=all&_r=0", name: "Fatehpur Sikri")
          m = c.complete!
          # What happens if we hit Foursquare API after Google?
        end

        xit "correctly identifies the most prominent Gem Palace and locates" do
          # Gem Palace and not the Jewelry store?
        end

        xit "saves Marrakech, Morocco as city not bar" do
          c = completed_data(filename: 'travelmap', scrape_url: "http://www.tripadvisor.com/TravelMapHome", name: "Marrakech, Morocco")
          m = c.complete!
          # Currently saving as So Lounge | Sofitel Marrakech?  
        end

      end
    end

    def completed_data(filename:, scrape_url:, name: nil)
      data = yml_data(filename, scrape_url, name)
      Completer.new(data, @user)
    end

    def place_hash(overwrite_hash={}, place_additions={})
      {
        place: {
          names: ["La Paletteria"],
          street_addresses: ["Calle Santo Domingo, No. 3-88"],
          locality: "Cartagena",
          country: "Colombia"
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
        plan: { name: "36 Hours in Cartagena, Colombia - NYTimes.com" }
      }
    end
  end
end
