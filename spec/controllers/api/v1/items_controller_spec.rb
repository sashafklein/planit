require 'rails_helper'

describe Api::V1::ItemsController, :vcr do

  include ScraperHelper

  describe "create" do

    before do
      @user = create(:user)
      @place1 = create(:place)
      @place2 = create(:place)
      @place3 = create(:place)
      @mark1 = create(:mark, {place_id: @place1.id, user_id: @user.id })
      @mark2 = create(:mark, {place_id: @place2.id, user_id: @user.id })
      @item1 = create(:item, {mark_id: @mark1.id })
      @plan1 = create(:plan, {user_id: @user.id })
    end

    it "requires a user" do
      post :create, data

      expect(response.status).to eq(403)
    end

    it "creates a marks, items, and plan with name and places" do
      sign_in @user      
      post :create, data

      expect(Mark.count).to eq(3)
      expect(Item.count).to eq(4)
      expect(Plan.count).to eq(2)
      expect(Plan.last.name).to eq("Whatup Bitches")
      expect(Plan.last.places.pluck(:id)).to eq(Place.all.pluck(:id))
    end

  end

  def data
    {
      plan_name: "Whatup Bitches",
      place_ids: Place.all.pluck(:id)
    }
  end
end