require 'rails_helper'

describe PlanMod do
  describe "manifest methods" do

    before do 
      @plan = create(:plan)
      @i1 = create(:item)
      @i2 = create(:item)
      @plan.add_to_manifest(object: @i1)
    end

    describe "add_to_manifest" do

      it "defaults to adding to the end of the list" do
        expect( @plan.manifest.first ).to hash_eq( { class: 'Item', id: @i1.id, detail: 'Food' } )
        
        @plan.add_to_manifest(object: @i2)
        expect( @plan.manifest.first ).to hash_eq( { class: 'Item', id: @i1.id, detail: 'Food' } )
        expect( @plan.manifest.last ).to hash_eq( { class: 'Item', id: @i2.id, detail: 'Food' } )
      end

      it "can take a specific location" do
        @plan.add_to_manifest(object: @i2, location: 0)
        expect( @plan.manifest.first ).to hash_eq( { class: 'Item', id: @i2.id, detail: 'Food' } )
        expect( @plan.manifest.last ).to hash_eq( { class: 'Item', id: @i1.id, detail: 'Food' } )
      end

      it "can take an object to precede" do
        @plan.add_to_manifest(object: @i2, before: @i1)
        expect( @plan.manifest.first ).to hash_eq( { class: 'Item', id: @i2.id, detail: 'Food' } )
        expect( @plan.manifest.last ).to hash_eq( { class: 'Item', id: @i1.id, detail: 'Food' } )
        @plan.add_to_manifest(object: @i1, before: @i2)
        expect( @plan.manifest.map(&:id) ).to eq [@i1.id, @i2.id, @i1.id]
      end 

    end

    describe "remove_from_manifest" do

      before do 
        @plan.add_to_manifest(object: @i2)
        @plan.add_to_manifest(object: @i1)
      end

      it "removes them all" do
        expect( @plan.manifest.length ).to eq 3
        @plan.remove_from_manifest(object: @i1)
        expect( @plan.manifest.map(&:id) ).to eq [@i2.id]
      end

      it "can remove a singular object from a particular location" do
        expect( @plan.manifest.length ).to eq 3

        @plan.remove_from_manifest(object: @i1, location: 2)
        expect( @plan.manifest.map(&:id) ).to eq [@i1.id, @i2.id]

        @plan.remove_from_manifest(object: @i1, location: 1)
        expect( @plan.manifest.map(&:id) ).to eq [@i1.id, @i2.id] # won't delete with bad location
      end
    end

    describe "move_in_manifest" do

      it "moves objects in the manifest by index" do
        @plan.add_to_manifest(object: @i2)
        @plan.add_to_manifest(object: @i1)
        @plan.add_to_manifest(object: (@i3 = create(:item)) )

        expect( @plan.manifest.map(&:id) ).to eq [@i1.id, @i2.id, @i1.id, @i3.id]
        @plan.move_in_manifest(from: 3, to: 0)
        expect( @plan.reload.manifest.map(&:id) ).to eq [@i3.id, @i1.id, @i2.id, @i1.id]
        @plan.move_in_manifest(from: 0, to: 3)
        expect( @plan.reload.manifest.map(&:id) ).to eq [@i1.id, @i2.id, @i1.id, @i3.id]
        @plan.move_in_manifest(from: 1, to: 2)
        expect( @plan.reload.manifest.map(&:id) ).to eq [@i1.id, @i1.id, @i2.id, @i3.id]
        @plan.move_in_manifest(from: 1, to: 3)
        expect( @plan.reload.manifest.map(&:id) ).to eq [@i1.id, @i2.id, @i3.id, @i1.id]
      end

      it "handles two objects" do
        @plan.add_to_manifest(object: @i2)

        expect( @plan.manifest.map(&:id) ).to eq [@i1.id, @i2.id]
        @plan.move_in_manifest(from: 0, to: 1)
        expect( @plan.reload.manifest.map(&:id) ).to eq [@i2.id, @i1.id]
        @plan.move_in_manifest(from: 1, to: 0)
        expect( @plan.manifest.map(&:id) ).to eq [@i1.id, @i2.id]
      end

      it "handles moving adjacent forward" do
        @plan.add_to_manifest object: @i2
        @plan.add_to_manifest object: (@i3 = create(:item))

        expect( @plan.manifest.map(&:id) ).to eq [@i1.id, @i2.id, @i3.id]
        @plan.move_in_manifest(from: 0, to: 1)
        expect( @plan.reload.manifest.map(&:id) ).to eq [@i2.id, @i1.id, @i3.id]
        @plan.move_in_manifest(from: 1, to: 2)
        expect( @plan.reload.manifest.map(&:id) ).to eq [@i2.id, @i3.id, @i1.id]
        @plan.move_in_manifest(from: 2, to: 1)
        expect( @plan.reload.manifest.map(&:id) ).to eq [@i2.id, @i1.id, @i3.id]
      end
    end
  end
end