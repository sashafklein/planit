require 'rails_helper'

describe Plan do 

  describe 'add nearby' do

    before do
      @user = create(:user)
      @plan = create(:plan, {user_id: @user.id})
      @data = { "asciiName"=>"San Francisco", "adminName1"=>"California", "countryName"=>"United States", "fclName"=>"city, village,...", "geonameId"=>5391959, "lat"=>"37.77493", "lon"=>"-122.41942", "searchStrings"=>"['San Francisco','San Fran']" }
    end

    it 'owner adds new nearby' do
      expect( Location.count + ObjectLocation.count + LocationSearch.count ).to eq 0
      expect{ @plan.add_nearby( @data, @user ) }.to change{ (Location.count + ObjectLocation.count + LocationSearch.count) }.by 3
    end

    it 'somone else trys to add new nearby, and is rejected' do
      expect( Location.count + ObjectLocation.count + LocationSearch.count ).to eq 0
      expect{ @plan.add_nearby( @data, create(:user) ) }.to change{ (Location.count + ObjectLocation.count + LocationSearch.count) }.by 2
    end

    it 'owner adds an existing nearby, and only adds to location search database' do
      @plan.add_nearby( @data, @user )
      expect( Location.count + ObjectLocation.count + LocationSearch.count ).to eq 3
      expect{ @plan.add_nearby( @data, @user ) }.to change{ (Location.count + ObjectLocation.count + LocationSearch.count) }.by 1
    end

  end

  describe '#copy(new_user)' do

    before do
      @owner = create(:user, name: 'Owner User')
      @plan = create(:plan, user: @owner)
      %w(first second third).each do |name|
        item = create(:item, place_options: { names: [name]}, plan: @plan)
      end
      [@plan.items.first, @plan.items.last].each{ |i| @plan.add_to_manifest(object: i) }
      @user = create(:user, name: 'New User')
    end

    it "handles redundancy" do
      expect{ 
        @plan.copy!(new_user: @user)
        @plan.copy!(new_user: @user)
      }.not_to raise_error
    end

    it "handles lineage correctly" do
      new_plan = @plan.copy!(new_user: @user)
      expect( new_plan.first_ancestor ).to eq @plan
      expect( new_plan.last_ancestor ).to eq @plan
      expect( new_plan.first_ancestor_copied_at ).to be_within( 0.5.seconds ).of DateTime.now
      expect( new_plan.last_ancestor_copied_at ).to be_within( 0.5.seconds ).of DateTime.now

      sleep 1
      new_user = create(:user)

      newest_plan = new_plan.copy!(new_user: new_user)
      expect( newest_plan.first_ancestor ).to eq @plan
      expect( newest_plan.first_ancestor_copied_at ).to eq new_plan.first_ancestor_copied_at
      expect( newest_plan.last_ancestor ).to eq new_plan
      expect( newest_plan.last_ancestor_copied_at ).not_to eq new_plan.last_ancestor_copied_at
      expect( newest_plan.last_ancestor_copied_at ).to be_within( 0.5.seconds ).of DateTime.now
    end

    it "creates a new plan (with the new user), new items, and new marks; it ignores the manifest" do
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

      expect( plan2.name ).to eq "Copy of '#{@plan.name}' by #{@owner.name}"

      expect( plan2.manifest.length ).to eq 0
    end

    it "creates a new plan (with the new user), new items, and new marks; it repoints the manifest if specified" do
      mark_count = Mark.count
      item_count = Item.count
      place_count = Place.count
      @plan.copy!(new_user: @user, copy_manifest: true)
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
      note = create(:note, obj: @plan.items.first, source: @owner)
      expect{ @plan.copy!(new_user: @user) }.to change{ Note.count }.by 1

      new_note = Plan.last.items.find{ |i| i.name == 'first' }.notes.first

      expect( new_note ).not_to eq note
      expect( new_note.body ).to eq note.body
      expect( new_note.source ).to eq note.source
      expect( new_note.obj ).not_to eq note.obj
      expect( new_note.obj.mark.place ).to eq note.obj.mark.place
    end

    it "copies sources of marks, and sources the original plan" do
      source = create(:source, obj: @plan.items.first.mark)

      expect{ @plan.copy!(new_user: @user) }.to change{ Source.count }.by 1
      new_mark_source = Plan.last.items.find{ |i| i.mark.place.name == 'first' }.mark.sources.first
      expect( new_mark_source ).not_to eq source
      expect( new_mark_source.attributes.to_sh.slice(:full_url, :description) ).to hash_eq source.attributes.to_sh.slice(:full_url, :description)
    end

    it "rolls it all back if it hits an error somewhere" do
      expect_any_instance_of(Item).to receive(:copy!).and_raise
      expect{ @plan.copy!(new_user: @user) }.to raise_error
      expect( Item.count ).to eq 3
      expect( Mark.count ).to eq 3
      expect( Plan.count ).to eq 1
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

      it "handles redundancy" do
        item_count = Item.count
        mark_count = Mark.count
        place_count = Place.count

        5.times do
          new_item = @plan.add_item_from_place_data!(@user, @data)
        end

        expect( Item.count ).to eq item_count + 1
        expect( Mark.count ).to eq mark_count + 1
        expect( Place.count ).to eq place_count        
      end

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