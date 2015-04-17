require 'rails_helper'

describe Plan do 

  describe '#copy(new_user)' do

    before do
      @owner = create(:user)
      @plan = create(:plan, user: @owner)
      %w(first second third).each do |name|
        item = create(:item, place_options: { names: [name]}, plan: @plan)
      end
      [@plan.items.first, @plan.items.last].each{ |i| @plan.add_to_manifest(object: i) }
      @user = create(:user, name: 'New User')
    end

    it "creates a new plan (with the new user), new items, and new marks, and repoints the manifest to the right items" do
      mark_count = Mark.count
      item_count = Item.count
      place_count = Place.count
      @plan.copy!(new_user: @user)
      expect( Mark.count ).to eq( mark_count * 2 )
      expect( Item.count ).to eq( item_count * 2 )
      expect( Place.count ).to eq place_count
      expect( Plan.count ).to eq 2

      plan2 = Plan.last
      expect( plan2.user ).to eq @user
      plan2.items.each do |item|
        expect( @plan.items.pluck(:id) ).not_to include( item.id )
      end

      old_manifest_items = Item.where(id: @plan.manifest.map(&:id) )
      new_manifest_items = Item.where(id: plan2.manifest.map(&:id) )
      expect( old_manifest_items.map{ |i| i.mark.place.name } ).to eq new_manifest_items.map{ |i| i.mark.place.name }
    end

    it "copies notes and keeps them pointed at the original user" do
      note = create(:note, object: @plan.items.first, source: @owner)
      expect{ @plan.copy!(new_user: @user) }.to change{ Note.count }.by 1

      new_note = Plan.last.items.find{ |i| i.name == 'first' }.notes.first

      expect( new_note ).not_to eq note
      expect( new_note.body ).to eq note.body
      expect( new_note.source ).to eq note.source
      expect( new_note.object ).not_to eq note.object
      expect( new_note.object.mark.place ).to eq note.object.mark.place
    end

    it "copies sources of marks, and sources the original plan" do
      source = create(:source, object: @plan.items.first.mark)

      expect{ @plan.copy!(new_user: @user) }.to change{ Source.count }.by 1
      new_mark_source = Plan.last.items.find{ |i| i.mark.place.name == 'first' }.mark.sources.first
      expect( new_mark_source ).not_to eq source
      expect( new_mark_source.attributes.to_sh.slice(:full_url, :description) ).to hash_eq source.attributes.to_sh.slice(:full_url, :description)
    end

    it "rolls it all back if it hits an error somewhere" do
      expect_any_instance_of(Mark).to receive(:dup_without_relations!).and_raise
      expect{ @plan.copy!(new_user: @user) }.to raise_error
      expect( Item.count ).to eq 3
      expect( Mark.count ).to eq 3
      expect( Plan.count ).to eq 1
    end

  end

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