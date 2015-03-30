require 'rails_helper'

module Scrapers

  describe Nationalgeographic do

    include ScraperHelper

    it "parses tayrona correctly" do 
      run_test 'tayrona', 'http://www.nationalgeographic.com/favorites/colombia/tayrona-national-park/reviews/935/'
    end

    # it "parses guadalupe correctly" do 
    #   run_test 'guadalupe', 'http://travel.nationalgeographic.com/travel/national-parks/guadalupe-mountains-national-park/'
    # end

  end
end 