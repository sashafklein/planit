module Scrapers
  class Eater < Services::SiteScraper

    attr_accessor :section_array, :days
    def initialize(url, page)
      super(url, page)
    end

    def card

    end

    def data
      binding.pry
      {
        name: name,
        full_address: full_address,
        street_address: street_address,
        locality: locality,
        region: region,
        postalCode: postalCode,
        country: country,
        phone: phone,
        website: website,
        category: category,
        price_info: priceInfo,
        source_notes: sourceNotes,
        rating: rating,
        ranking: ranking,
        images: imageList,
        tab_image: photoToUse,
        image_credit: siteName,
        source: siteName,
        source_url: document.URL,
        lat: lat,
        lon: lon
      }
    end

    private

    def self.specific_scraper(url, page)
      new(url, page)
    end

    def name
      choose([
        ['.m-review-scratch__venue', Proc.new {|el| trim(el.inner_html.split("</span>")[1])} ],
        ['.m-map-point-title[:visible]', Proc.new {|el| trim(el.inner_html.split("</span>")[1])} ]
      ])
    end

    def full_address
    end

    def street_address
    end

    def locality
    end

    def region
    end

    def postalCode
    end

    def country
    end

    def phone
    end

    def website
    end

    def category
    end

    def price_info
    end

    def source_notes
    end

    def rating
    end

    def ranking
    end

    def images
    end

    def tab_image
    end

    def image_credit
    end

    def source
    end

    def lat
    end

    def lon
    end

    def choose(selectors_and_blocks)
      binding.pry
      selectors_and_blocks.each do |selector_and_block|
        if ( el = css(selector_and_block[0]) ).any?
          return call(selector_and_block[1], el)
        end
      end
    end

  end
end