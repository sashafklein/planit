require 'spec_helper'

module Services
  describe SiteScraper do
    describe "initialize" do

      let(:url) { 'http://www.tripadvisor.com/Restaurant_Review-g1066456-d1679642-Reviews-Fuunji-Shibuya_Tokyo_Tokyo_Prefecture_Kanto.html' }
      let(:page) { File.read File.join(File.join('spec', 'support', 'pages', 'tripadvisor', "fuunji.html")) } 

      it "handles no page", :vcr do
        page_scraper = SiteScraper.build(url, page)
        expect(page_scraper).to be_a Scrapers::TripadvisorMod::ItemReview
        
        url_scraper = SiteScraper.build(url)
        expect(url_scraper).to be_a Scrapers::TripadvisorMod::ItemReview

        expect( 
          url_scraper.page.css('body .content_block').inner_html.first(200)
        ).to eq( 
          page_scraper.page.css('body .content_block').inner_html.first(200)
        )
      end

      it "errors without url" do
        expect{ SiteScraper.build(nil, page) }.to raise_error
      end
    end
  end
end