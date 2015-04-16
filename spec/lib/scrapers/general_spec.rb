require 'rails_helper'

module Scrapers

  xdescribe General do

    include ScraperHelper


    # describe "website" do
    #   before { @url = "website" }
    #   it "parses the page" do 
    #     raw_test(data) 
    #     puts "name attempts #{name_attempts}"
    #   end
    # end

    # describe "website" do
    #   before { @url = "website" }
    #   it "parses the page" do 
    #     raw_test(data) 
    #     puts "name attempts #{name_attempts}"
    #   end
    # end

    # describe "website" do
    #   before { @url = "website" }
    #   it "parses the page" do 
    #     raw_test(data) 
    #     puts "name attempts #{name_attempts}"
    #   end
    # end

    # describe "website" do
    #   before { @url = "website" }
    #   it "parses the page" do 
    #     raw_test(data) 
    #     puts "name attempts #{name_attempts}"
    #   end
    # end

    # ARTICLES

    # REDIRECTS/LOG-IN NECESSARY -- NEED TO SEND VIA BROWSER CLIENT
    # describe "http://www.nytimes.com/2014/12/14/travel/vail-the-thrifty-way.html?hpw&rref=travel&action=click&pgtype=Homepage&module=well-region&region=bottom-well&WT.nav=bottom-well" do
    #   before { @url = "http://www.nytimes.com/2014/12/14/travel/vail-the-thrifty-way.html?hpw&rref=travel&action=click&pgtype=Homepage&module=well-region&region=bottom-well&WT.nav=bottom-well" }
    #   it "parses the page" do 
    #     raw_test(data) 
    #   end
    # end

    # # THIS ONE IS GNARLY -- NAMES TWO LOCATIONS, AT WHICH THERE IS A POP-UP!!
    # describe "http://www.washingtonpost.com/blogs/going-out-guide/wp/2014/11/13/jeremiah-langhorne-pops-up-at-dgs-delicatessen-mockingbird-hill/" do
    #   before { @url = "http://www.washingtonpost.com/blogs/going-out-guide/wp/2014/11/13/jeremiah-langhorne-pops-up-at-dgs-delicatessen-mockingbird-hill/" }
    #   it "parses the page" do 
    #     raw_test(data) 
    #   end
    # end

    # describe "http://www.latimes.com/travel/la-tr-d-punta-mita-20141214-story.html#page=1" do
    #   before { @url = "http://www.latimes.com/travel/la-tr-d-punta-mita-20141214-story.html#page=1" }
    #   it "parses the page" do 
    #     raw_test(data) 
    #   end
    # end

    # describe "http://www.latimes.com/travel/deals/la-trb-las-vegas-bobby-flay-mesa-grill-10-year-menu-20141014-story.html" do
    #   before { @url = "http://www.latimes.com/travel/deals/la-trb-las-vegas-bobby-flay-mesa-grill-10-year-menu-20141014-story.html" }
    #   it "parses the page" do 
    #     raw_test(data) 
    #     # expect_equal(data, [
    #     #   place: {
    #     #     name: "mesa grill",
    #     #     locality: "Las Vegas",
    #     #     country: "United States of America",
    #     #     nearby: "Las Vegas, United States of America",
    #     #     website: "http://www.mesagrill.com/las-vegas-restaurant/",
    #     #   },
    #     #   place: {
    #     #     name: "caesars palace",
    #     #     locality: "Las Vegas",
    #     #     country: "United States of America",
    #     #     nearby: "Las Vegas, United States of America",
    #     #     website: "http://www.caesarspalace.com",
    #     #   }
    #     #   ])
    #   end
    # end

    # describe "http://www.sfgate.com/restaurants/article/Chris-Cosentino-s-pork-ragu-survives-the-5825375.php" do
    #   before { @url = "http://www.sfgate.com/restaurants/article/Chris-Cosentino-s-pork-ragu-survives-the-5825375.php" }
    #   it "parses the page" do 
    #     expect_equal(data, [
    #       place: {
    #         name: "Porcellino",
    #         locality: "San Francisco",
    #         country: "United States of America",
    #         nearby: "San Francisco, United States of America",
    #         website: "http://www.porcellinosf.com",
    #         phones: "(415) 641-4500",
    #       }
    #       ])
    #   end
    # end

    # OTHER WEBSITES

    describe "http://novareresbiercafe.com" do
      before { @url = "http://novareresbiercafe.com" }
      it "parses the page" do 
        expect_equal(data, yaml(:novare))
      end
    end

    describe "http://bluespoonme.com/is_good/" do
      before { @url = "http://bluespoonme.com/is_good/" }
      it "parses the page" do 
        expect_equal(data, yaml(:blue_spoon))
      end
    end

    # NOW COMPLETELY LACKING IN DATA
    # describe "http://www.biteintomaine.com" do
    #   before { @url = "http://www.biteintomaine.com" }
    #   it "parses the page" do 
    #     expect_equal(data, [
    #       place: {
    #         name: "Bite into Maine",
    #         locality: "Portland",
    #         country: "United States of America",
    #         nearby: "Portland, United States of America",
    #       },
    #       scraper_url: "http://www.biteintomaine.com",
    #       ])
    #   end
    # end

    # GNARLY LACK OF ACTUAL DATA
    # describe "http://dwelltimecambridge.com" do
    #   before { @url = "http://dwelltimecambridge.com" }
    #   it "parses the page" do 
    #     raw_test(data) 
    #   end
    # end

    describe "http://www.mesagrill.com/las-vegas-restaurant/" do
      before { @url = "http://www.mesagrill.com/las-vegas-restaurant/" }
      it "parses the page" do 
        expect_equal(data, yaml(:mesa_grill))
      end
    end

    # PERPETUAL REDIRECT PAGE?
    # describe "http://www.homebuenosaires.com/EN/index" do
    #   before { @url = "http://www.homebuenosaires.com/EN/index" }
    #   it "parses the page" do 
    #     raw_test(data) 
    #     puts "name attempts #{name_attempts}"
    #   end
    # end
    
    # DELETED THEIR DATA, AGAIN
    # describe "http://www.frenchie-restaurant.com/" do
    #   before { @url = "http://www.frenchie-restaurant.com/" }
    #   it "parses the page" do 
    #     expect_equal(data, [
    #       place: {
    #         name: "Frenchie Restaurant",
    #         locality: "Paris", 
    #         country: "France",
    #         nearby: "Paris, France",
    #         full_address: "Restaurant Frenchie 5-6, rue du Nil 75002 Paris Métro 3: Sentier",
    #         phones: "+33 (0)1.40.39.96.19",
    #         postal_code: "75002",
    #       },
    #       scraper_url: "http://www.frenchie-restaurant.com/",
    #       ])
    #   end
    # end

    describe "http://www.fairmont.com/san-francisco/" do
      before { @url = "http://www.fairmont.com/san-francisco/" }
      it "parses the page correctly" do
        expect_equal(data, yaml(:fairmont))
      end
    end

    describe "http://www.jdvhotels.com/hotels/california/san-francisco-hotels/hotel-vitale/" do
      before { @url = "http://www.jdvhotels.com/hotels/california/san-francisco-hotels/hotel-vitale/" }
      it "parses the page correctly" do
        expect_equal(data, yaml(:hotel_vitale))
      end
    end

    describe "http://www.mandarinoriental.com/sanfrancisco/" do
      before { @url = "http://www.mandarinoriental.com/sanfrancisco/" }
      xit "parses the page correctly" do
        expect_equal(data, yaml(:mandarin_sf))
      end
    end

    describe "http://www.inpraiseofsardines.typepad.com/contigosf" do
      before { @url = "http://www.inpraiseofsardines.typepad.com/contigosf" }
      it "parses the page correctly" do
        expect_equal(data, yaml(:contigo))
      end
    end

    describe "http://www.mountlaviniahotel.com/front/index.php" do
      before { @url = "http://www.mountlaviniahotel.com/front/index.php" }
      xit "parses the page correctly" do
        expect_equal(data, yaml(:mount_lavinia_hotel))
      end
    end

    describe "http://docrickettssf.com/" do
      before { @url = "http://docrickettssf.com/" }
      it "parses the page correctly" do
        expect_equal(data, yaml(:doc_ricketts))
      end
    end

    # PRIVATE FUNCTIONS

    def raw_test(data)
      if has_name?(data) && has_locale?(data)
        puts "#{@url} gets #{data}"
      else
        expect(has_name?(data)).to equal(true)
        expect(has_locale?(data)).to equal(true)
      end
    end

    def has_name?(data)
      if data.first[:place][:name] && data.first[:place][:name].length > 1
        return true
      end
    end

    def has_locale?(data)
      if data.first[:place][:nearby] && data.first[:place][:nearby].length > 1
        return true
      elsif  data.first[:place][:lat] && data.first[:place][:lat].length > 1 && data.first[:place][:lon] && data.first[:place][:lon].length > 1 
        return true
      end
    end

    def yaml(name)
      YAML.load_file File.join(Rails.root, 'spec', 'support', 'pages', 'general', "#{name}.yml")
    end

  end
end 