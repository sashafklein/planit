require 'rails_helper'
 
describe Api::V1::GeonamesController do
  describe 'search' do

    it "hits Geonames with the string query params STRICT", :vcr do
      sign_in create(:user)
      get :search, query: "Hawaii"
      
      expect( response_body.geonames.first.name ).to eq "Honolulu"
      expect( response_body.geonames.first.countryCode ).to eq "US"
    end

    it "hits Geonames with the string query params as NEIGHBORHOOD", :vcr do
      sign_in create(:user)
      get :search, query: "the mission"
      
      expect( response_body.geonames.map{ |g| g.name } ).to include "Mission District"
      expect( response_body.geonames.map{ |g| g.adminName1 } ).to include "California"
      expect( response_body.geonames.map{ |g| g.countryCode } ).to include "US"
    end

    it "returns best picks and countrynames without codes", :vcr do
      sign_in create(:user)
      get :search, query: "bali"

      expect( response_body.geonames.map{ |g| g.countryName } ).to include "Indonesia"
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
