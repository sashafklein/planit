require 'rails_helper'
 
describe Api::V1::FoursquareController do
  describe 'search' do

    it "hits Foursquare with the near and query params", :vcr do
      sign_in create(:user)
      expect_any_instance_of( Apis::Foursquare ).to receive(:explore).and_call_original
      get :search, near: 'Tokyo, Japan', query: 'Fuunji'

      expect( response_body.response.groups.first.items.first.venue.categories.first.name ).to sorta_eq "Ramen"
    end

    it "measures Foursquare with the near and query params" do
      sign_in create(:user)
      allow( Apis::Foursquare ).to receive(:new).and_return(Apis::Foursquare.new)
      expect_any_instance_of( Apis::Foursquare ).to receive(:explore).at_least(:once).and_call_original
      expect( Benchmark.measure{ get :search, near: '20.75028,-156.50028', query: 'beach' }.real ).to be_within(1).of 1
    end

    xit "measures Foursquare with the near and query params" do
      sign_in create(:user)
      expect_any_instance_of( Foursquare2::Client ).to receive(:explore_venues).and_call_original
      expect( Benchmark.measure{ get :search, near: '20.75028,-156.50028', query: 'beach' }.real ).to be < 1
    end

    it "gets images in explore mode", :vcr do
      sign_in create(:user)
      expect_any_instance_of( Apis::Foursquare ).to receive(:explore).and_call_original
      get :search, near: 'Tokyo, Japan', query: 'Jiro'

      expect( response_body.response.groups.first.items.first.venue.categories.first.name ).to sorta_eq 'Sushi'
    end

  end
end
