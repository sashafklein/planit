require 'rails_helper'

module Scrapers

  describe Eater do

    include ScraperHelper

    it "parses nico correctly" do
      run_test 'nico', 'http://sf.eater.com/venue/nico'
    end

    it "parses sitka correctly" do
      run_test 'sitka', 'http://www.eater.com/2014/10/17/6994765/sitka-and-spruce-restaurant-review'
    end

    # it "parses # correctly" do
    #   run_test suppers: 'http://sf.eater.com/2014/11/7/7174885/sunday-suppers-trendy'
    # end
    
    it "parses 'apizza correctly" do
      run_test 'apizza-scholls', 'http://pdx.eater.com/maps/portland-best-restaurants-kachka-davenport/apizza-scholls'
    end

    it "parses thoumieux correctly" do
      run_test 'thoumieux', 'http://www.eater.com/maps/the-eater-paris-heatmap-where-to-eat-right-now/gateaux-thoumieux'
    end

  end
end 