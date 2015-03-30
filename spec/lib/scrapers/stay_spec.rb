require 'rails_helper'

module Scrapers

  describe Stay do

    include ScraperHelper

    it "parses pierre correctly" do
      run_test 'pierre', 'http://www.stay.com/new-york/hotel/4986/the-pierre-a-taj-hotel-new-york/'
    end

    it "parses jetsetters correctly" do
      run_test 'jetsetters', 'http://www.stay.com/new-york/guides/296846-dbc0095d/new-york-for-jetsetters/'
    end

    it "parses nyhigh correctly" do
      run_test 'nyhigh', 'http://www.stay.com/new-york/'
    end

  end
end 