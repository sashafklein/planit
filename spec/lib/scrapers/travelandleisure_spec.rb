require 'rails_helper'

module Scrapers

  describe Travelandleisure do

    include ScraperHelper

    it "parses pestagua correctly" do
      run_test 'pestagua', 'http://www.travelandleisure.com/travel-guide/cartagena/hotels/casa-pestagua'
    end

    # it "parses lively correctly"
    #   run_test 'lively', 'http://www.travelandleisure.com/trips/trip-guide-to-lively-cartagena-colombia'
    # end

    # it "parses retreat correctly"
    #   run_test 'retreat', 'http://www.travelandleisure.com/articles/cartagena-a-hidden-retreat'
    # end

  end
end 