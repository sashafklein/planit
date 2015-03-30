require 'rails_helper'

module Scrapers

  describe Tripadvisor do

    include ScraperHelper

    it "parses travelmap correctly" do
      run_test :travelmap, 'http://www.tripadvisor.com/TravelMapHome'
    end
    
    it "parses jerome correctly" do
      run_test :jerome, 'http://www.tripadvisor.com/Hotel_Review-g29141-d82776-Reviews-Hotel_Jerome_An_Auberge_Resort-Aspen_Colorado.html'
    end
    
    it "parses fuunji correctly" do
      run_test :fuunji, 'http://www.tripadvisor.com/Restaurant_Review-g1066456-d1679642-Reviews-Fuunji-Shibuya_Tokyo_Tokyo_Prefecture_Kanto.html'
    end
    
    it "parses umegaoka correctly" do
      run_test :umegaoka, 'http://www.tripadvisor.com/ShowUserReviews-g1066456-d1678469-r237573192-Umegaoka_Sushi_No_Midori_Sohonten_Shibuya-Shibuya_Tokyo_Tokyo_Prefecture_Kanto.html#REVIEWS'
    end
    
    it "parses bogota correctly" do
      run_test :bogota, 'http://www.tripadvisor.com/Guide-g294074-l186-Bogota.html'
    end
    
    it "parses kokkari correctly" do
      run_test :kokkari, "http://www.tripadvisor.com/Restaurant_Review-g60713-d353917-Reviews-Kokkari_Estiatorio-San_Francisco_California.html"
    end

  end
end 