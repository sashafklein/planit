require 'spec_helper'

describe Api::V1::Users::MarksController do
  describe "create" do

    before do
      @user = create(:user)
    end

    it "requires a user" do
      post :create, mark: mark_params, user_id: 'nonexistent'

      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)['message']).to eq("User not found")
      expect{ post :create, mark: mark_params }.to raise_error
    end

    it "successfully serializes a mark with its place, place's photos, and empty item array", :vcr do
      expect(Services::Completer).to receive(:new).and_call_original
      post :create, mark: mark_params, user_id: @user.id

      expect(response_body[:place][:id]).to be_a Integer
      expect(response_body[:place][:lat]).to eq(mark_params[:place][:lat])
      expect(response_body[:place][:lon]).to eq(mark_params[:place][:lon])
      expect(response_body[:place][:names]).to eq( [mark_params[:place][:name]] )
      expect(response_body[:place][:locality]).to eq(mark_params[:place][:locality])
      expect(response_body[:place][:region]).to eq(mark_params[:place][:region])
      expect(response_body[:place][:street_addresses]).to eq( [mark_params[:place][:street_address]] )

      expect(response_body[:items].any?).to eq false

      img = response_body[:place][:images].first
      expect(img[:url]).to eq "https://irs3.4sqi.net/img/general/200x200/2261_a2HV5M7fSEIO1oiL0DHbvHMGdJ3xHEozUVUY0U5w0ag.jpg"
      expect(img[:source]).to eq "FourSquare"

      expect(response_body[:user][:email]).to eq @user.email
    end
  end

  describe 'scrape' do

    before do
      @user = create(:user)
    end

    context "single place" do

      let(:fuunji_url) { 'http://www.tripadvisor.com/Restaurant_Review-g1066456-d1679642-Reviews-Fuunji-Shibuya_Tokyo_Tokyo_Prefecture_Kanto.html' }
      let(:fuunji_doc) { File.read File.join(File.join('spec', 'support', 'pages', 'tripadvisor', "fuunji.html")) } 
      
      it "sets CORS headers", :vcr do
        post :scrape, url: fuunji_url, page: fuunji_doc, user_id: @user.id
        expect(response.headers).to eq(
          {
            "X-Frame-Options"=>"SAMEORIGIN",
            "X-XSS-Protection"=>"1; mode=block",
            "X-Content-Type-Options"=>"nosniff",
            "Access-Control-Allow-Origin"=>"*",
            "Access-Control-Allow-Methods"=>"POST, GET, PUT, DELETE, OPTIONS",
            "Access-Control-Allow-Headers"=>"Origin, Content-Type, Accept, Authorization, Token, Data-Type, X-Requested-With",
            "Access-Control-Max-Age"=>"1728000",
            "Content-Type"=>"application/json; charset=utf-8"
          }
        )
      end

      it "errors without the url", :vcr do
        post :scrape, data: fuunji_doc, user_id: @user.id
        expect(response.code).to eq '500'
      end

      it "calls the right scraper", :vcr do
        fake_scraper_data = [{ key: 'whatever'}]
        expect(Scrapers::TripadvisorMod::ItemReview).to receive(:new).with(fuunji_url, fuunji_doc) { double({ data: fake_scraper_data }) }
        expect(Services::MassCompleter).to receive(:new).with(fake_scraper_data, @user).and_return( double(complete!: true) )
        post :scrape, url: fuunji_url, page: fuunji_doc, user_id: @user.id
      end

      it "saves new information to the user", :vcr do
        expect( @user.marks.count ).to eq 0
        
        post :scrape, url: fuunji_url, page: fuunji_doc, user_id: @user.id
        mark = @user.marks.first

        expect(mark.place.name).to eq "Fuunji"
        expect(mark.place.street_addresses).to include "代々木2-14-3" # TODO -- get rid of the shitty Yoyogi address
        expect(mark.place.images.first).to be_a Image
      end

      it "works identically without the page", :vcr do
        expect( @user.marks.count ).to eq 0
        
        post :scrape, url: fuunji_url, user_id: @user.id
        mark = @user.marks.first

        expect(mark.place.name).to eq "Fuunji"
        expect(mark.place.street_addresses).to include "代々木2-14-3" # TODO -- get rid of the shitty Yoyogi address
        expect(mark.place.images.first).to be_a Image
      end
    end

    context "whole lotta places" do
      it "serializes and saves EVERYTHING", :vcr do
        expect( @user.marks.count ).to eq 0
        post :scrape, url: 'http://www.nytimes.com/2010/07/04/travel/04hours.html?pagewanted=all&_r=0', user_id: @user.id

        plan = @user.plans.first
        items = plan.items

        expect( @user.plans.count ).to eq 1
        expect( @user.items.count ).to eq Place.count
        expect( @user.marks.count ).to eq Place.count
        expect( @user.items ).to eq plan.items
        expect( items.count ).to eq 18
        expect( response_body.count ).to eq 18

        scraped = YAML.load_file( File.join(Rails.root, 'spec', 'support', 'pages', 'nytimes', 'bogota.yml') )
        expect( scraped.map{ |e| e['place'] }.map{ |p| p['name'] }.compact.sort ).to eq( items.places.pluck(:names).map(&:first).sort )

      end
    end
  end

  def mark_params
    {
      place: {
        lat: 37.750902,
        lon: -122.434327,
        name: "Contigo",
        phone: "4152850250",
        street_address: "1320 Castro St",
        country: "United States",
        region: "CA",
        locality: "San Francisco", 
      }
    }
  end
end