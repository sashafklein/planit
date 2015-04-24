require 'rails_helper'
 
describe Api::V1::GeonamesController do
  describe 'search' do

    it "hits Geonames with the string query params STRICT", :vcr do
      sign_in create(:user)
      get :search, query: "Hawaii"
      
      expect( response_body.geonames.first.name ).to eq "Hawaii"
      expect( response_body.geonames.first.countryCode ).to eq "US"
    end

    it "hits Geonames with the string query params FUZZY", :vcr do
      sign_in create(:user)
      get :search, query: "Lundin"
      
      expect( response_body.geonames.first.name ).to eq "London"
      expect( response_body.geonames.first.countryCode ).to eq "GB"
    end

    it "hits Geonames with the string query params as NEIGHBORHOOD", :vcr do
      sign_in create(:user)
      get :search, query: "the mission"
      
      expect( response_body.geonames.map{ |g| g.name } ).to include "Mission District"
      expect( response_body.geonames.map{ |g| g.adminName1 } ).to include "California"
      expect( response_body.geonames.map{ |g| g.countryCode } ).to include "US"
    end

  end
  describe 'point' do

    xit "hits Geonames with the latlon params", :vcr do
      sign_in create(:user)
      get :point, lat: "37.75993", lon: "-122.41914"
      
      expect( response_body.geonames.first.name ).to eq "Mission"
      expect( response_body.geonames.first.adminName1 ).to eq "Texas"
      expect( response_body.geonames.first.countryCode ).to eq "US"
    end

  end
end
