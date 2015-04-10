require 'rails_helper'
 
describe Api::V1::FoursquareController do
  describe 'search' do

    it "hits Foursquare with the near and query params", :vcr do
      sign_in create(:user)
      expect_any_instance_of( Foursquare2::Client ).to receive(:explore_venues).and_call_original
      get :search, near: 'Tokyo, Japan', query: 'Fuunji'

      expect( response_body.length ).to be > 0
      expect( response_body.first.categories.first ).to sorta_eq "Ramen"
    end
  end
end
