require 'spec_helper'

module Scrapers

  describe General do

    include ScraperHelper


    # describe "website" do
    #   before { @url = "website" }
    #   it "parses the page" do raw_test(data) end
    # end

    # describe "website" do
    #   before { @url = "website" }
    #   it "parses the page" do raw_test(data) end
    # end

    # describe "website" do
    #   before { @url = "website" }
    #   it "parses the page" do raw_test(data) end
    # end

    # describe "website" do
    #   before { @url = "website" }
    #   it "parses the page" do raw_test(data) end
    # end

    # describe "website" do
    #   before { @url = "website" }
    #   it "parses the page" do raw_test(data) end
    # end

    # describe "website" do
    #   before { @url = "website" }
    #   it "parses the page" do raw_test(data) end
    # end

    # describe "website" do
    #   before { @url = "website" }
    #   it "parses the page" do raw_test(data) end
    # end

    # describe "website" do
    #   before { @url = "website" }
    #   it "parses the page" do raw_test(data) end
    # end

    # describe "website" do
    #   before { @url = "website" }
    #   it "parses the page" do raw_test(data) end
    # end

    # describe "website" do
    #   before { @url = "website" }
    #   it "parses the page" do raw_test(data) end
    # end

    # describe "website" do
    #   before { @url = "website" }
    #   it "parses the page" do raw_test(data) end
    # end

    # describe "website" do
    #   before { @url = "website" }
    #   it "parses the page" do raw_test(data) end
    # end

    describe "http://www.mesagrill.com/las-vegas-restaurant/" do
      before { @url = "http://www.mesagrill.com/las-vegas-restaurant/" }
      it "parses the page" do 
        raw_test(data) 
      end
    end

    # describe "website" do
    #   before { @url = "website" }
    #   it "parses the page" do 
    #     raw_test(data) 
    #     puts "name attempts #{name_attempts}"
    #   end
    # end

    # describe "http://www.banrepcultural.org/museo-botero" do
    #   before { @url = "http://www.banrepcultural.org/museo-botero" }
    #   it "parses the page" do raw_test(data) end
    # end

    describe "http://www.fairmont.com/san-francisco/" do
      before { @url = "http://www.fairmont.com/san-francisco/" }
      it "parses the page correctly" do
        expect_equal(data, [
          place: {
            name: "The Fairmont San Francisco",
            street_address: "950 Mason Street San Francisco California, United States 94108 Maps &amp; Directions TEL + 1 415 772 5000 FAX + 415 772 5013 International Numbers",
            locality: "San Francisco", 
            postal_code: "94108",
            country: "United States of America",
            nearby: "San Francisco, United States of America",
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
            postal_code: "94104",
            lat: "37.792457",
            lon: "-122.400789",
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
          }
          ])
      end
    end

    describe "http://www.mountlaviniahotel.com/front/index.php" do
      before { @url = "http://www.mountlaviniahotel.com/front/index.php" }
      it "parses the page correctly" do
        expect_equal(data, [
          place: {
            name: "Mount Lavinia",
            locality: "Colombo", 
            country: "Sri Lanka",
            nearby: "Colombo, Sri Lanka",
          }
          ])
      end
    end

    describe "http://www.everyonesanoriginal.com/destinations/united-states/the-fairmont-san-francisco" do
      before { @url = "http://www.everyonesanoriginal.com/destinations/united-states/the-fairmont-san-francisco" }
    end

    describe "http://docrickettssf.com/" do
      before { @url = "http://docrickettssf.com/" }
      it "parses the page correctly" do
        expect_equal(data, [
          place: {
            name: "Doc Ricketts",
            lat: "37.7967858", 
            lon: "-122.4048005",
            phones: "415-649-6191",          }
          ])
      end
    end


    def raw_test(data)
      if has_name?(data) && has_locale?(data)
        puts "#{@url} gets #{data}"
      else
        puts "name attempts #{name_attempts}"
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