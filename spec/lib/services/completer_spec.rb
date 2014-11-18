require 'spec_helper'
module Services
  describe Completer do

    describe "complete!" do

      before do 
        @user = create(:user)
        allow_any_instance_of(PlaceValidator).to receive(:validate) {}
      end

      context "new place" do
        context "with no sequence or plan data" do
          it "saves and returns an associated mark, rounded out by Geocoder and FourSquare API", :vcr do
            c = Completer.new(place_hash, @user)
            mark = c.complete!

            expect(mark.user).to eq @user
            
            place = mark.place
            expect(place.name).to eq place_hash[:place][:names][0]
            expect(place.street_address).to eq place_hash[:place][:street_addresses].first
            expect(place.locality).to eq place_hash[:place][:locality]
            expect(place.country).to eq place_hash[:place][:country]
          end

          it "grabs more info from FourSquare", :vcr do
            expect( Image.count ).to eq 0
            c = Completer.new(place_hash, @user)
            mark = c.complete!

            expect(mark.place.images.first).to be_present
          end

          it "ignores but retains unusable data" do
            expect_any_instance_of(Services::PlaceCompleter).to receive(:api_complete!)
            expect_any_instance_of(Services::PlaceCompleter).to receive(:geocode!)

            c = Completer.new(place_hash({made_up: 'whatever'}), @user)
            c.complete!
            expect(c.decremented_attrs).to eq({ made_up: 'whatever'})
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
          expect_any_instance_of(Services::PlaceCompleter).to receive(:api_complete!)
          expect_any_instance_of(Services::PlaceCompleter).to receive(:geocode!)

          mark_count = Mark.count
          place_count = Place.count

          c = Completer.new(place_hash, @user)

          completed_mark = c.complete!

          expect(Mark.count).to eq(mark_count)
          expect(Place.count).to eq(place_count)

          expect(completed_mark).to eq @mark
        end

        it "fills any missing info", :vcr do
          completed_mark = Completer.new(place_hash, @user).complete!

          expect(@mark.reload.region).to eq('Bolivar') # From FourSquare
        end
      end

      context "with sequence data" do
        context "without legs" do
          it "creates an item, associated with day and plan" do
            expect_any_instance_of(Services::PlaceCompleter).to receive(:api_complete!)
            expect_any_instance_of(Services::PlaceCompleter).to receive(:geocode!)
            expect(Item.count).to eq(0)

            c = Completer.new(place_hash(sequence_hash), @user).complete!
            item = c.items.first

            expect(item.plan.name).to eq sequence_hash[:plan][:name]
            expect(item.order).to eq(1)
            expect(item.start_time).to eq('03:00')
            expect(item.duration).to eq(0.5)
            expect(item.weekday).to eq('Friday')
            expect(item.day.order).to eq(1)
            expect(item.leg).to be_present # Creates a blank leg inside the plan
          end
        end
      end
    end

    def place_hash(overwrite_hash={})
      {
        place: {
          names: ["La Paletteria"],
          street_addresses: ["Calle Santo Domingo, No. 3-88"],
          locality: "Cartagena",
          country: "Colombia"
        }
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
