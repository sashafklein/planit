require 'spec_helper'
module Completers
  describe Completer, :vcr do

    include ScraperHelper

    describe "complete!" do

      before do 
        @user = create(:user)
        allow_any_instance_of(PlaceValidator).to receive(:validate) {}
      end

      context "new place" do
        context "with no sequence or plan data" do
          it "saves and returns an associated mark, rounded out by Geocoder and FourSquare API" do
            c = Completer.new(place_hash, @user)
            mark = c.complete!

            expect(mark.user).to eq @user
            
            place = mark.place
            expect(place.name).to eq place_hash[:place][:names][0]
            expect(place.street_address).to eq place_hash[:place][:street_addresses].first
            expect(place.locality).to eq place_hash[:place][:locality]
            expect(place.country).to eq place_hash[:place][:country]
          end

          it "grabs more info from FourSquare" do
            expect( Image.count ).to eq 0
            c = Completer.new(place_hash, @user)
            mark = c.complete!

            expect(mark.place.images.first).to be_present
          end

          it "ignores but retains unusable data" do
            expect_any_instance_of(Completers::PlaceCompleter).to receive(:foursquare_complete!)
            expect_any_instance_of(Completers::PlaceCompleter).to receive(:narrow_with_geocoder!)

            c = Completer.new(place_hash({made_up: 'whatever'}), @user)
            c.complete!
            expect(c.decremented_attrs).to eq({ made_up: 'whatever'})
          end

          it "uses scraped images and FourSquare images" do
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
          expect(@mark.reload.place.extra.symbolize_keys).to eq({random_other: 'value', four_square_id: "509ef2b9e4b01b9e49f1d25c", menu_url: nil, mobile_menu_url: nil})
          expect(@mark.place.flags.first).to eq "Place ##{@mark.place.id} merged with nonpersisted place. Added: {:names=>[\"La Paletteria\", \"La Palettería\"], :street_addresses=>[\"Calle Santo Domingo, No. 3-88\", \"Cll Santo Domingo # 36 - 86\"]}"
        end
      end

      context "with sequence data" do
        context "without legs" do
          it "creates an item, associated with day and plan" do
            expect_any_instance_of(Completers::PlaceCompleter).to receive(:foursquare_complete!)
            expect_any_instance_of(Completers::PlaceCompleter).to receive(:narrow_with_geocoder!)
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
          expect( m.place.flags ).to include ("Failed to find geolocation data for locality")

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

        it "creates Boom Boom Room in context" do
          m = Completer.new(yml_data('jetsetters', 'http://www.stay.com/new-york/guides/296846-dbc0095d/new-york-for-jetsetters/', 'Boom Boom Room'), @user).complete!

          expect(m.country).to eq "United States"
          expect(m.region).to eq "New York"
          expect(m.locality).to eq "New York"
          expect(m.place.completion_steps).to eq ["Narrow", "FourSquare", "Translate"]
          expect(m.place.flags).to eq ["Took information from identically named, distant FourSquare data with LatLon: 40.7406045, -74.0078798. Old lat lon: 40.7406045, -74.0078798"]

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
          m = Completer.new(yml_data('nyhigh', 'http://www.stay.com/new-york/', 'Tribute WTC Visitor Center'), @user).complete!

          expect(m.country).to eq "United States"
          expect(m.region).to eq "New York"
          expect(m.locality).to eq "New York"
          expect(m.name).to eq "Tribute WTC Visitor Center"
          i = m.items.first
          expect(i.plan.name).to eq "New York City Guide"
        end
      end
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
