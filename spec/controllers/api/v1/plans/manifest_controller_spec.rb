require 'rails_helper'

describe Api::V1::Plans::ManifestController do

  before do 
    @user = create(:user)
    sign_in @user
    @plan = create(:plan, user: @user)
    @item = create(:item, plan: @plan)
  end

  describe 'add' do
    
    it "adds an item to the plan" do
      expect_any_instance_of( Plan ).to receive(:add_to_manifest).with(object: @item, location: 0)
      post :add, id: @plan.id, obj_id: @item.id, obj_class: 'Item', location: 0
    end

    it "takes the location param into account" do
      expect_any_instance_of( Plan ).to receive(:add_to_manifest).with(object: @item, location: 2)
      post :add, id: @plan.id, obj_id: @item.id, obj_class: 'Item', location: 2
    end
  end

  describe 'remove' do

    it "calls remove_from_manifest" do
      expect_any_instance_of( Plan ).to receive(:remove_from_manifest).with(object: @item, location: 2)
      post :remove, id: @plan.id, obj_id: @item.id, obj_class: 'Item', location: 2
    end
  end

  describe 'move' do
    it "calls move_in_manifest" do
      expect_any_instance_of( Plan ).to receive(:move_in_manifest).with( from: 1, to: 2 )
      post :move, id: @plan.id, from: '1', to: '2'
    end
  end


end