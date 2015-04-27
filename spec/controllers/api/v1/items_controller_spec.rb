require 'rails_helper'
 
describe Api::V1::ItemsController do
  describe 'show' do

    before do
      @user = create( :user)
      @plan = create( :plan, user: @user )
    end

    it "fetches serialized 30-item plan in under 0.5s" do
      sign_in @user
      30.times do create( :item, plan_id: @plan.id, place_options: { image_count: 10 } ) end
      expect( time = Benchmark.measure{ get :index, where: "{ plan_id: #{@plan.id} }" }.real ).to be < 0.5
      puts time.to_s + "s for 30"
    end

    it "fetches serialized 90-item plan in under 1.5s" do
      sign_in @user
      90.times do create( :item, plan_id: @plan.id, place_options: { image_count: 10 } ) end
      expect( time = Benchmark.measure{ get :index, where: "{ plan_id: #{@plan.id} }" }.real ).to be < 1.5
      puts time.to_s + "s for 90"
    end

  end
end
