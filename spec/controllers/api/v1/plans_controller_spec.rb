require 'rails_helper'

describe Api::V1::PlansController, :vcr do

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
      expect(Plan.last.places.pluck(:id)).to array_eq(Place.all.pluck(:id))
    end

  end

  describe "adds" do

    before do
      @user = create(:user)
      @place1 = create(:place)
      @place2 = create(:place)
      @place3 = create(:place)
      @mark1 = create(:mark, {place_id: @place1.id, user_id: @user.id })
      @mark2 = create(:mark, {place_id: @place2.id, user_id: @user.id })
      @item1 = create(:item, {mark_id: @mark1.id })
      @plan = create(:plan, {user_id: @user.id})
    end

    it "only adds places for which user has marks" do
      sign_in @user      
      post :add_items, { id: @plan.id, place_ids: Place.all.pluck(:id) }

      expect(@plan.places.pluck(:id)).to eq([@place1.id,@place2.id])
    end

  end

  describe "removes" do

    before do
      @user = create(:user)
      @plan = create(:plan, {user_id: @user.id})
      @place1 = create(:place)
      @place2 = create(:place)
      @place3 = create(:place)
      @mark1 = create(:mark, {place_id: @place1.id, user_id: @user.id })
      @mark2 = create(:mark, {place_id: @place2.id, user_id: @user.id })
      @mark3 = create(:mark, {place_id: @place3.id, user_id: @user.id })
      @item1 = create(:item, {mark_id: @mark1.id })
      @item2 = create(:item, {mark_id: @mark2.id, plan_id: @plan.id })
      @item3 = create(:item, {mark_id: @mark3.id, plan_id: @plan.id })
      @item4 = create(:item, {plan_id: @plan.id })
    end

    it "places (and items) from a plan" do
      sign_in @user      

      expect(@plan.items.count).to eq(3)

      post :destroy_items, { id: @plan.id, place_ids: [@place2.id,@place3.id] }

      expect(@plan.items.count).to eq(1)
      expect(@plan.items.first).to eq(@item4)
    end

  end

  describe "add_item_from_place_data" do

    before do
      @plan = create(:plan, user: create(:user))
      @data = build(:place).attributes.to_sh.except(:id)
      allow( Rails.env ).to receive(:test?).and_return(false)
    end

    it "calls plan.add_item_from_place_data! with the data" do
      sign_in @plan.user

      expect( PlanAddItemFromPlaceDataJob ).to receive(:perform_later).with(user_id: @plan.user_id, plan_id: @plan.id.to_s, data: @data.map_val{ |v| v.is_a?(Numeric) ? v.to_s : v }.compact )

      post :add_item_from_place_data, id: @plan.id, place: @data
    end

    it "handles new add of raw foursquare data quickly" do
      sign_in @plan.user
      fs_data = { name: "Boot & Shoe Service", names: ["Boot & Shoe Service"], image_url: "https://irs0.4sqi.net/img/general/69x69/1099625_GOsG8FaDrCfr3tsYTeD8zeaZ39lh1mqDCxUz9N5pEMg.jpg", foursquare_icon: "https://ss3.4sqi.net/img/categories_v2/food/pizza_bg_64.png", foursquare_id: "4b1c4e34f964a520c90524e3", categories: ["Pizza Place"], street_addresses: ["3308 Grand Ave"], locality: "Oakland", region: "CA", country: "United States", lat: 37.81285866282477, lon: -122.24683541720094, images: [{ url: "https://irs0.4sqi.net/img/general/69x69/1099625_GOsG8FaDrCfr3tsYTeD8zeaZ39lh1mqDCxUz9N5pEMg.jpg", source: "Foursquare"}] }
      expect( time = Benchmark.measure{ post :add_item_from_place_data, id: @plan.id, place: fs_data }.real ).to be < 0.1
      # puts time.to_s + "s"
      expect( response_body.name ).to eq "Boot & Shoe Service"
    end

    it "errors if there's no current_user" do
      expect_any_instance_of( Plan ).not_to receive(:add_item_from_place_data!)

      post :add_item_from_place_data, id: @plan.id, place: @data

      expect( response.code ).to eq '403'
    end

  end

  def data
    {
      plan_name: "Whatup Bitches",
      place_ids: Place.all.pluck(:id)
    }
  end
end