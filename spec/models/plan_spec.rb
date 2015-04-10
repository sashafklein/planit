require 'rails_helper'

describe Plan do 

  describe "manifest methods" do

    before do 
      @plan = create(:plan)
      @i_1 = create(:item)
      @i_2 = create(:item)
      @plan.add_to_manifest(object: @i_1)
    end

    describe "add_to_manifest" do

      it "defaults to adding to the end of the list" do
        expect( @plan.manifest.first ).to hash_eq( { class: 'Item', id: @i_1.id, detail: 'Food' } )
        
        @plan.add_to_manifest(object: @i_2)
        expect( @plan.manifest.first ).to hash_eq( { class: 'Item', id: @i_1.id, detail: 'Food' } )
        expect( @plan.manifest.last ).to hash_eq( { class: 'Item', id: @i_2.id, detail: 'Food' } )
      end

      it "can take a specific location" do
        @plan.add_to_manifest(object: @i_2, location: 0)
        expect( @plan.manifest.first ).to hash_eq( { class: 'Item', id: @i_2.id, detail: 'Food' } )
        expect( @plan.manifest.last ).to hash_eq( { class: 'Item', id: @i_1.id, detail: 'Food' } )
      end

      it "can take an object to precede" do
        @plan.add_to_manifest(object: @i_2, before: @i_1)
        expect( @plan.manifest.first ).to hash_eq( { class: 'Item', id: @i_2.id, detail: 'Food' } )
        expect( @plan.manifest.last ).to hash_eq( { class: 'Item', id: @i_1.id, detail: 'Food' } )
        @plan.add_to_manifest(object: @i_1, before: @i_2)
        expect( @plan.manifest.map(&:id) ).to eq [@i_1.id, @i_2.id, @i_1.id]
      end 

    end

    describe "remove_from_manifest" do

      before do 
        @plan.add_to_manifest(object: @i_2)
        @plan.add_to_manifest(object: @i_1)
      end

      it "removes them all" do
        expect( @plan.manifest.length ).to eq 3
        @plan.remove_from_manifest(object: @i_1)
        expect( @plan.manifest.map(&:id) ).to eq [@i_2.id]
      end

      it "can remove a singular object from a particular location" do
        expect( @plan.manifest.length ).to eq 3

        @plan.remove_from_manifest(object: @i_1, location: 2)
        expect( @plan.manifest.map(&:id) ).to eq [@i_1.id, @i_2.id]

        @plan.remove_from_manifest(object: @i_1, location: 1)
        expect( @plan.manifest.map(&:id) ).to eq [@i_1.id, @i_2.id] # won't delete with bad location
      end
    end

    describe "move_in_manifest" do

      before do 
        @plan.add_to_manifest(object: @i_2)
        @plan.add_to_manifest(object: @i_1)
        @plan.add_to_manifest(object: (@i_3 = create(:item)) )
      end

      it "moves objects in the manifest by index" do
        expect( @plan.manifest.map(&:id) ).to eq [@i_1.id, @i_2.id, @i_1.id, @i_3.id]
        @plan.move_in_manifest(from: 3, to: 0)
        expect( @plan.manifest.map(&:id) ).to eq [@i_3.id, @i_1.id, @i_2.id, @i_1.id]
        @plan.move_in_manifest(from: 0, to: 4)
        expect( @plan.manifest.map(&:id) ).to eq [@i_1.id, @i_2.id, @i_1.id, @i_3.id]
        @plan.move_in_manifest(from: 1, to: 2)
        expect( @plan.manifest.map(&:id) ).to eq [@i_1.id, @i_2.id, @i_1.id, @i_3.id] # doesn't do anything, because we're inserting BEFORE
        @plan.move_in_manifest(from: 1, to: 3)
        expect( @plan.manifest.map(&:id) ).to eq [@i_1.id, @i_1.id, @i_2.id, @i_3.id]
      end
    end
  end

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