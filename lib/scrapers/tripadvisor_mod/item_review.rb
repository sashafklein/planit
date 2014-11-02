module Scrapers
  module TripadvisorMod

    # PAGE SETUP

    class ItemReview < Tripadvisor

      def initialize(url, page)
        super(url, page)
        @scrape_target = %w(#area-main #article article)
      end

      def global_data
        { 
          ratings_base: 5
          # site_name: "Trip Advisor"
        }
      end

      # PAGE 
      
      def activity_data(activity, activity_index)
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
          lon: lon,
        }
      end

      # OPERATIONS

    end
  end
end