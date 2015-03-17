require 'rails_helper'

describe Api::V1::Users::MarksController, :vcr do

  include ScraperHelper

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

    it "successfully serializes a mark with its place, place's photos, and empty item array" do
      expect(Completers::Completer).to receive(:new).and_call_original
      post :create, mark: mark_params, user_id: @user.id

      place = response_body.place
      expect( place.id ).to be_a Integer
      expect( place.lat ).to be_within(0.001).of mark_params[:place][:lat]
      expect( place.lon ).to be_within(0.001).of mark_params[:place][:lon]
      expect( place.names ).to eq( [mark_params[:place][:name]] )
      expect( place.locality ).to eq(mark_params[:place][:locality])
      expect( place.region ).to eq("California") # Expanded
      expect( place.street_addresses ).to eq( [mark_params[:place][:street_address]].map{ |a| a.gsub("St", "Street") } )

      expect( place.menu ).to eq( "https://foursquare.com/v/contigo/49c6bdfef964a52077571fe3/menu" )
      expect( place.mobile_menu ).to eq( "https://foursquare.com/v/49c6bdfef964a52077571fe3/device_menu" )
      expect( place.reservations ).to eq true
      expect( place.reservations_link ).to eq 'http://www.opentable.com/single.aspx?rid=45052&ref=9601'

      expect( place.hours ).to hash_eq({
        "tue"=>[["1730", "2200"]], 
        "wed"=>[["1730", "2200"]],
        "thu"=>[["1730", "2200"]],
        "fri"=>[["1730", "2200"]], 
        "sat"=>[["1730", "2200"]], 
        "sun"=>[["1730", "2130"]] 
      })
      expect( response_body.items.any? ).to eq false

      img = place.images.find{ |i| i.url == "https://irs3.4sqi.net/img/general/#{Completers::ApiVenue::FoursquareExploreVenue::IMAGE_SIZE}/2261_a2HV5M7fSEIO1oiL0DHbvHMGdJ3xHEozUVUY0U5w0ag.jpg"}
      expect( img.source ).to eq "Foursquare"

      expect( response_body.user.email ).to eq @user.email
    end
  end

  describe 'scrape' do

    before do
      @user = create(:user)
    end

    context "single place" do

      let(:fuunji_url) { 'http://www.tripadvisor.com/Restaurant_Review-g1066456-d1679642-Reviews-Fuunji-Shibuya_Tokyo_Tokyo_Prefecture_Kanto.html' }
      let(:fuunji_doc) { File.read File.join(File.join('spec', 'support', 'pages', 'tripadvisor', "fuunji.html")) } 
      
      it "sets CORS headers" do
        post :scrape, url: fuunji_url, page: fuunji_doc, user_id: @user.id
        expect(response.headers).to hash_eq(
          {
            "X-XSS-Protection"=>"1; mode=block",
            "X-Content-Type-Options"=>"nosniff",
            "Access-Control-Allow-Origin"=>"*",
            "Access-Control-Allow-Methods"=>"POST, GET, PUT, DELETE, OPTIONS",
            "Access-Control-Allow-Headers"=>"Origin, Content-Type, Accept, Authorization, Token, Data-Type, X-Requested-With",
            "Access-Control-Max-Age"=>"1728000"
          }, [], ['Content-Type']
        )
      end

      it "errors without the url" do
        post :scrape, data: fuunji_doc, user_id: @user.id
        expect(response.code).to eq '500'
      end

      it "calls the right scraper" do
        fake_scraper_data = [{ place: { nearby: 'whatever'} }]
        expect(Scrapers::TripadvisorMod::ItemReview).to receive(:new).with(fuunji_url, fuunji_doc) { double({ data: fake_scraper_data }) }
        expect(Completers::MassCompleter).to receive(:new).with(fake_scraper_data, @user, fuunji_url).and_return( double(delay_complete!: true) )
        post :scrape, url: fuunji_url, page: fuunji_doc, user_id: @user.id, delay: false
      end

      it "saves new information to the user" do
        expect( @user.marks.count ).to eq 0
        
        post :scrape, url: fuunji_url, page: fuunji_doc, user_id: @user.id, delay: false
        mark = @user.marks.first
        
        expect( mark.place.flags.where(name: "Triangulated").count ).to eq 1
        
        expect(mark.place.name).to eq "Fuunji"
        expect(mark.place.street_addresses).to include "代々木2-14-3" # TODO -- get rid of the shitty Yoyogi address
        expect(mark.place.images.first).to be_a Image
      end

      it "gets the Hotel Century Southern" do
        expect{
          post :scrape, url: 'http://www.tripadvisor.com/Hotel_Review-g1066456-d307326-Reviews-Hotel_Century_Southern_Tower-Shibuya_Tokyo_Tokyo_Prefecture_Kanto.html', page: read('tripadvisor', 'hotel_century_southern.html'), user_id: @user.id, delay: false
        }.to change{ Mark.count }.by 1
        options = Mark.all.first.place_options
        expect( options.first.name ).to include "Hotel Century Southern"
      end

      it "gets full data from 36 hours los cabos" do
        expect{
          post :scrape,
            url: 'http://www.nytimes.com/2015/03/15/travel/what-to-do-in-36-hours-in-los-cabos-mexico.html?rref=collection/column/36-hours', page: read('nytimes', 'los_cabos.html'), user_id: @user.id, delay: false
        }.to change{ Mark.count }.by 18
      end

      it "gets full data from 36 hours berkeley" do
        expect{
          post :scrape,
            url: 'http://www.nytimes.com/2014/10/12/travel/things-to-do-in-36-hours-in-berkeley-calif.html', page: read('nytimes', 'berkeley_new.html'), user_id: @user.id, delay: false
        }.to change{ Mark.count }.by 16
      end

      it "gets The Hall without erroring on the hours" do
        expect{ 
          post :scrape, url: "http://www.yelp.com/biz/the-hall-san-francisco", user_id: @user.id, page: read('yelp', 'the_hall.html'), delay: false
        }.to change{ Mark.count }.by 1
        place = Mark.first.place
        expect( place.name ).to eq "The Hall"
        hour_flag = place.flags.where(name: 'Conflicting Hash Values').first
        expect( hour_flag.details ).to eq "Hours"

        expect( hour_flag.info ).to hash_eq({
          place_in_progress: {
            mon: [["0900", "2000"]], 
            tue: [["0900", "2000"]], 
            wed: [["0900", "2000"]], 
            thu: [["0900", "2000"]], 
            fri: [["0900", "2000"]]
          },
          foursquare_refine: {
            mon: [["0800", "2000"]],
            tue: [["0800", "2000"]],
            wed: [["0800", "2000"]],
            thu: [["0800", "2000"]],
            fri: [["0800", "2000"]],
            sat: [["0800", "2000"]]
          }
        })
        
        expect( place.hours ).to hash_eq({
          mon: [["0900", "2000"]],
          tue: [["0900", "2000"]],
          wed: [["0900", "2000"]],
          thu: [["0900", "2000"]],
          fri: [["0900", "2000"]],
          sat: [["0800", "2000"]]
        }) # Combines additively
      end

      xit "works identically without the page" do
        expect( @user.marks.count ).to eq 0
        
        post :scrape, url: 'http://www.contigosf.com/', user_id: @user.id, delay: false

        mark = @user.marks.first

        expect(mark.place.name).to eq "Contigo"
        expect(mark.place.street_addresses).to include "1320 Castro St" # TODO -- get rid of the shitty Yoyogi address
        expect(mark.place.images.first).to be_a Image
      end

      it "works identically without the page" do
        expect( @user.marks.count ).to eq 0
        
        post :scrape, url: 'http://www.booking.com/hotel/co/tayrona-tented-lodge.html', user_id: @user.id, delay: false

        mark = @user.marks.first

        expect(mark.place.name).to eq "Tayrona Tented Lodge"
        expect(mark.place.full_address).to eq "Km 38 +300 mts, vía Santa Marta- Rioacha, Santa Marta, 575000, Colombia"
        expect(mark.place.images.first).to be_a Image
      end

      it "flags the failure if it doesn't scrape enough data" do
        expect{
          post :scrape, url: "http://stackoverflow.com/questions/10113366/load-jquery-with-javascript-and-use-jquery", user_id: @user.id, delay: false
        }.to change{ @user.flags.count }.by 1

        expect( @user.marks.first ).to be_nil 
        expect( @user.flags.first.name ).to eq "Scrape and completion failed"
        expect( @user.flags.first.info ).to hash_eq( {
          "url"=>"http://stackoverflow.com/questions/10113366/load-jquery-with-javascript-and-use-jquery",
          "data"=>
            [{"place"=>
              {
                "lat"=>nil,
                "lon"=>nil,
                "name"=>"Load jQuery with Javascript and use jQuery",
                "nearby"=>"",
                "full_address"=>nil,
                "street_address"=>nil,
                "locality"=>nil,
                "region"=>nil,
                "postal_code"=>nil,
                "country"=>nil,
                "phones"=>nil,
                "hours"=>nil,
                "map_href"=>nil
              },
              "scraper_url"=>"http://stackoverflow.com/questions/10113366/load-jquery-with-javascript-and-use-jquery"
            }]
        }) 
      end
      
    end

    context "whole lotta places" do
      xit "serializes and saves EVERYTHING" do
        expect( @user.marks.count ).to eq 0
        
        post :scrape, url: 'http://www.nytimes.com/2010/07/04/travel/04hours.html?pagewanted=all&_r=0', user_id: @user.id, delay: false

        plan = @user.plans.first
        items = plan.items

        expect( @user.plans.count ).to eq 1

        expect( @user.items.count ).to eq Place.count
        expect( @user.items.count ).to be_within(3).of YAML.load_file("#{Rails.root}/spec/support/pages/nytimes/bogota.yml").map{ |h| h['place']['name'] }.compact.count
        expect( @user.marks.count ).to eq Place.count
        
        expect( @user.items.pluck(:id).sort ).to eq plan.items.pluck(:id).sort
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