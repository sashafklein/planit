require 'spec_helper'

module Services
  describe SiteScraper do
    describe "build" do

      it "initializes a NytimesScraper with the right URL" do
        url = 'http://www.nytimes.com/2003/12/12/travel/journeys-36-hours-amelia-island-fla.html'
        scraper = SiteScraper.build(url, 'doesnt-matter')
        expect( scraper.class ).to eq(Scrapers::Nytimes)
        expect( scraper.url ).to eq(url)
        expect( scraper.html.content ).to eq('doesnt-matter')
      end
      
    end
  end
end