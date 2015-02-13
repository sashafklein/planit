require 'rails_helper'

module Scrapers

  describe Tripadvisor do

    include ScraperHelper

    # 

    describe "travelmap" do

      before do 
        @base_name = 'travelmap'
        @url = 'http://www.tripadvisor.com/TravelMapHome'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    # 

    describe "jerome" do
      before do 
        @base_name = 'jerome'
        @url = 'http://www.tripadvisor.com/Hotel_Review-g29141-d82776-Reviews-Hotel_Jerome_An_Auberge_Resort-Aspen_Colorado.html'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    describe "fuunji" do

      before do 
        @base_name = 'fuunji'
        @url = 'http://www.tripadvisor.com/Restaurant_Review-g1066456-d1679642-Reviews-Fuunji-Shibuya_Tokyo_Tokyo_Prefecture_Kanto.html'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    describe "umegaoka" do

      before do 
        @base_name = 'umegaoka'
        @url = 'http://www.tripadvisor.com/ShowUserReviews-g1066456-d1678469-r237573192-Umegaoka_Sushi_No_Midori_Sohonten_Shibuya-Shibuya_Tokyo_Tokyo_Prefecture_Kanto.html#REVIEWS'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    describe "bogota" do

      before do 
        @base_name = 'bogota'
        @url = 'http://www.tripadvisor.com/Guide-g294074-l186-Bogota.html'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

  end
end 