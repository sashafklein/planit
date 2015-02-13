require 'rails_helper'

module Services
  describe SiteScraper, :vcr do
    describe "initialize" do

      let(:url) { 'http://www.contigo.com' }
      let(:page) { File.read File.join(File.join('spec', 'support', 'pages', 'contigosf', "contigo.html")) } 

      it "handles no page" do
        page_scraper = SiteScraper.build(url, page)
        expect(page_scraper).to be_a Scrapers::General
        
        url_scraper = SiteScraper.build(url)
        expect(url_scraper).to be_a Scrapers::General

        expect( 
          url_scraper.page.css('body .content_block').inner_html.first(300)
        ).to eq page_scraper.page.css('body .content_block').inner_html.first(300)
      end

      it "errors without url" do
        expect{ SiteScraper.build(nil, page) }.to raise_error
      end
    end
  end
end