require 'spec_helper'

module Scrapers

  describe General do

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
        expect_equal(data, [
          place: {
            name: "Novare Res Bier Café",
            locality: "Portland",
            country: "United States of America",
            nearby: "Portland, United States of America"
          }
          ])
      end
    end

    describe "http://bluespoonme.com" do
      before { @url = "http://bluespoonme.com" }
      it "parses the page" do 
        expect_equal(data, [
          place: {
            name: "Blue Spoon",
            locality: "Portland",
            country: "United States of America",
            nearby: "Portland, United States of America"
          }
          ])
      end
    end

    describe "http://www.biteintomaine.com" do
      before { @url = "http://www.biteintomaine.com" }
      it "parses the page" do 
        expect_equal(data, [
          place: {
            name: "Bite into Maine",
            locality: "Portland",
            country: "United States of America",
            nearby: "Portland, United States of America"
          }
          ])
      end
    end

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
        expect_equal(data, [
          place: {
            name: "Mesa Grill Las Vegas",
            full_address: "Mesa Grill Caesars Palace 3570 Las Vegas Blvd,Las Vegas, NV 89109",
            lat: "36.116557",
            lon: "-115.173261",
            postal_code: "89109",
            phones: "877.346.4642"
          }
          ])
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

    describe "http://www.reveillecoffee.com/" do
      before { @url = "http://www.reveillecoffee.com/" }
      it "parses the page" do 
        expect_equal(data, [
          place: {
            name: "Réveille Coffee Co",
            locality: "San Francisco", 
            country: "United States of America",
            nearby: "San Francisco, United States of America",
          }
          ])
      end
    end

    describe "http://www.frenchie-restaurant.com/" do
      before { @url = "http://www.frenchie-restaurant.com/" }
      it "parses the page" do 
        expect_equal(data, [
          place: {
            name: "Frenchie Restaurant",
            locality: "Paris", 
            country: "France",
            nearby: "Paris, France",
            full_address: "Restaurant Frenchie 5-6, rue du Nil 75002 Paris Métro 3 : Sentier",
            phones: "+33 (0)1.40.39.96.19",
            postal_code: "75002",
          }
          ])
      end
    end

    describe "http://www.fairmont.com/san-francisco/" do
      before { @url = "http://www.fairmont.com/san-francisco/" }
      it "parses the page correctly" do
        expect_equal(data, [
          place: {
            country: "California, United States",
            locality: "San Francisco", 
            name: "The Fairmont San Francisco Hotel",
            nearby: "San Francisco, California, United States",
            full_address: "950 Mason Street San Francisco California, United States 94108",
            phones: "1 866 540 4491",
            postal_code: "94108",
          }
          ])
      end
    end

    describe "http://www.jdvhotels.com/hotels/california/san-francisco-hotels/hotel-vitale/" do
      before { @url = "http://www.jdvhotels.com/hotels/california/san-francisco-hotels/hotel-vitale/" }
      it "parses the page correctly" do
        expect_equal(data, [
          place: {
            name: "Hotel Vitale",
            phones: "4158350300",
            locality: "San Francisco", 
            country: "United States of America",
            nearby: "San Francisco, United States of America",
            full_address: "8 Mission Street San Francisco, CA 94105",
            postal_code: "94105",
          }
        ])
      end
    end

    describe "http://www.mandarinoriental.com/sanfrancisco/" do
      before { @url = "http://www.mandarinoriental.com/sanfrancisco/" }
      it "parses the page correctly" do
        expect_equal(data, [
          place: {
            name: "Mandarin Oriental, San Francisco",
            street_address: "222 Sansome Street",
            full_address: "222 Sansome Street,  San Francisco,  CA  94104",
            postal_code: "94104",
            region: "CA",
            lat: "37.792457",
            lon: "-122.400789",
            phones: "+1 (415) 276 9888",
          }
          ])
      end
    end

    describe "http://www.contigosf.com/" do
      before { @url = "http://www.contigosf.com/" }
      it "parses the page correctly" do
        expect_equal(data, [
          place: {
            name: "Contigo",
            lat: "37.0625", 
            lon: "-95.677068",
            full_address: "1320 Castro Street, San Francisco, Ca 94114",
          }
          ])
      end
    end

    describe "http://www.mountlaviniahotel.com/front/index.php" do
      before { @url = "http://www.mountlaviniahotel.com/front/index.php" }
      it "parses the page correctly" do
        expect_equal(data, [
          place: {
            name: "Mount Lavinia Hotel",
            locality: "Colombo", 
            country: "Sri Lanka",
            nearby: "Colombo, Sri Lanka",
          }
          ])
      end
    end

    describe "http://docrickettssf.com/" do
      before { @url = "http://docrickettssf.com/" }
      it "parses the page correctly" do
        expect_equal(data, [
          place: {
            name: "Doc Ricketts",
            lat: "37.7967858", 
            lon: "-122.4048005",
            phones: "415-649-6191",  
            full_address: "124 Columbus Avenue, SF, CA",
          }
          ])
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

  end
end 