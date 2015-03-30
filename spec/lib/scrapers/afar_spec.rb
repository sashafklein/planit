module Scrapers
  describe Afar do

    include ScraperHelper
    
    it "parses desal correctly" do
      run_test :desal, 'http://www.afar.com/places/catedral-de-sal-zipaquira?context=travel-guide&country=colombia'
    end
  end
end