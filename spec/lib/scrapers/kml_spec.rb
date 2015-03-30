require 'rails_helper'

module Scrapers

  describe Googlemaps do

    include ScraperHelper
    
    it 'parses maine correctly' do 
      run_test 'maine', 'http://www.kml.com'
    end

    it 'parses japan correctly' do 
      run_test 'japan', 'http://www.kml.com'
    end

    it 'parsehot correctlys ' do 
      run_test 'hotbaths', 'http://www.kml.com'
    end

    it 'parses barcelona correctly' do 
      run_test 'barcelona', 'http://www.kml.com'
    end

  end

end 