require 'rails_helper'

describe Item do 
  describe "after actions", :vcr do

    before do
      @plan = Plan.create(name: 'Whatever Plan')
      @item = build(:item, plan_id: @plan.id)
      @location = create(:location)
      @location.build_out_location_hierarchy
      @item.place.object_locations.where( location_id: @location.id ).first_or_create      
    end

    it "on create - updates the plan's admin_2 locations" do
      expect( @plan.locations.count ).to eq 0
      expect( @plan.items.count ).to eq 0

      expect( @item.place.locations.first.name ).to eq 'Downtown'
      expect( @item.place.locations.first.admin_name_2 ).to eq 'San Francisco County'
      expect{ @item.save! }.to change{ @plan.reload.locations.reload.count }.to 1
      expect( @plan.items.count ).to eq 1

      expect( @plan.locations.first.name ).to eq 'San Francisco County'
    end

    describe "after_destroy" do

      before { @item.save! }

      it "on delete - deletes the plan's relevant admin_2 location" do
        expect{ @item.destroy }.to change{ @plan.locations.count }.from(1).to(0)
      end

      it "on delete - doesn't delete if another item points to the same location" do
        item2 = build(:item, plan_id: @plan.id)
        item2.place.object_locations.where( location_id: @location.id ).first_or_create!
        item2.save!

        expect( @plan.items.count ).to eq 2
        expect( @plan.locations.count ).to eq 1

        expect{ @item.destroy }.not_to change{ @plan.locations.count }
        expect{ item2.destroy }.to change{ @plan.locations.count }.from(1).to(0)
      end
    end
  end
end