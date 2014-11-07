require 'spec_helper'

describe Api::V1::MarksController do
  describe "create" do

    before do
      @user = create(:user)
      FourSquareCompleter.any_instance.stub(:complete!).and_return {}
    end

    it "requires a user" do
      post :create, mark: flat_hash

      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)['message']).to eq("User not found")
    end

    it "calls Mark.from_flat_hash!" do
      allow(Mark).to receive(:from_flat_hash).with(flat_hash).and_return({})
      post :create, mark: flat_hash, user_id: @user.id
    end

    it "successfully serializes a mark, place, and photo from the params" do
    end
  end

  describe 'scrape' do

    before do
      @user = create(:user)
    end

    let(:fuunji_url) { 'http://www.tripadvisor.com/Restaurant_Review-g1066456-d1679642-Reviews-Fuunji-Shibuya_Tokyo_Tokyo_Prefecture_Kanto.html' }
    let(:fuunji_doc) { File.read File.join(File.join('spec', 'support', 'pages', 'tripadvisor', "fuunji.html"))} 
    
    it "sets CORS headers" do
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

    it "can deal without the page" do
    end

    it "errors without the url" do
    end

    it "calls the right scraper" do
      expect(Scrapers::Tripadvisor).to receive(:build).with(fuunji_url, fuunji_doc)
      post :scrape, url: fuunji_url, page: fuunji_doc, user_id: @user.id
    end

    it "passes data into the completer" do
    end

    it "saves new information to the user" do
    end
  end

  def flat_hash
    {
      lat: 37.74422249388305,
      lon: -122.4352317663816,
      name: "Contigo",
      phone: "4152850250",
      street_address: "1320 Castro St",
      country: "United States",
      state: "CA",
      city: "San Francisco",
      photo: "https://irs3.4sqi.net/img/general/200x200/2261_a2HV5M7fSEIO1oiL0DHbvHMGdJ3xHEozUVUY0U5w0ag.jpg",
      category: "Spanish Restaurant",
      meal: true,
      lodging: false
    }
  end
end