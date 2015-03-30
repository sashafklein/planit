require 'rails_helper'

module Scrapers

  describe Frommers do

    include ScraperHelper

    it "parses arch correctly" do
      run_test 'arch', 'http://www.frommers.com/destinations/rome/attractions/866798'
    end

    it "parses inroma correctly" do
      run_test 'inroma', 'http://www.frommers.com/destinations/rome/restaurants/866665'
    end

    # CLEAN LISTS

    it "parses restaurantlist correctly" do
      run_test 'restaurantlist', 'http://www.frommers.com/destinations/rome/restaurants'
    end

    # MULTIPLE

    it "parses performingarts correctly" do
      run_test 'performingarts', 'http://www.frommers.com/destinations/rome/705646'
    end

    it "parses leyva correctly" do
      run_test 'leyva', 'http://www.frommers.com/destinations/bogota/278016'
    end

    it "parses threedays correctly" do
      run_test 'threedays', 'http://www.frommers.com/destinations/rome/705674'
    end

    it "parses cerveteri correctly" do
      run_test 'cerveteri', 'http://www.frommers.com/destinations/rome/705658'
    end

  end
end 