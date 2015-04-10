require 'rails_helper'

describe Plan do 
  describe "add_item_from_place_data" do

    before do 
      @user = create(:user)
      @plan = create(:plan)
      @data = build(:place).attributes.to_sh.except(:id)
    end
    
    context "with nothing" do
      it "builds all three" do
        item_count = Item.count
        mark_count = Mark.count
        place_count = Place.count

        new_item = @plan.add_item_from_place_data!(@user, @data)

        expect( Item.count ).to eq item_count + 1
        expect( Mark.count ).to eq mark_count + 1
        expect( Place.count ).to eq place_count + 1

        expect( new_item.mark.place.name ).to eq @data.names.first
        expect( new_item.plan ).to eq @plan
      end
    end

    context "with place" do
      
      before{ @place = create(:place, @data.compact.symbolize_keys) }

      it "builds the mark and item but keeps the place" do
        item_count = Item.count
        mark_count = Mark.count
        place_count = Place.count

        new_item = @plan.add_item_from_place_data!(@user, @data)

        expect( Item.count ).to eq item_count + 1
        expect( Mark.count ).to eq mark_count + 1
        expect( Place.count ).to eq place_count

        expect( new_item.mark.place.name ).to eq @data.names.first
        expect( new_item.mark.place ).to eq @place
        expect( new_item.plan ).to eq @plan
      end

      context "with mark" do

        before{ @mark = create(:mark, place: @place, user: @user) }

        it "builds the item, but nothing else" do
          item_count = Item.count
          mark_count = Mark.count
          place_count = Place.count

          new_item = @plan.add_item_from_place_data!(@user, @data)

          expect( Item.count ).to eq item_count + 1
          expect( Mark.count ).to eq mark_count
          expect( Place.count ).to eq place_count

          expect( new_item.mark.place.name ).to eq @data.names.first
          expect( new_item.mark.place ).to eq @place
          expect( new_item.mark ).to eq @mark
          expect( new_item.plan ).to eq @plan
        end

        context "with preexisting item" do

          before{ @item = create(:item, mark: @mark, plan: @plan) }

          it "builds nothing" do
            item_count = Item.count
            mark_count = Mark.count
            place_count = Place.count

            new_item = @plan.add_item_from_place_data!(@user, @data)

            expect( Item.count ).to eq item_count
            expect( Mark.count ).to eq mark_count
            expect( Place.count ).to eq place_count

            expect( new_item.mark.place.name ).to eq @data.names.first
            expect( new_item.mark.place ).to eq @place
            expect( new_item.mark ).to eq @mark
            expect( new_item ).to eq @item
            expect( new_item.plan ).to eq @plan
          end
        end

      end

    end

  end
end