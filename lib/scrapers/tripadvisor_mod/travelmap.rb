module Scrapers
  module TripadvisorMod

    # PAGE SETUP

    class Travelmap < Tripadvisor

      def initialize(url, page)
        super(url, page)
        @scrape_target = ["#GUIDE_DETAIL"]
        @order_no = 0
      end

      # PAGE 
      
      def activity_group(section)
        activities = page.inner_html.scan(/[:][{]["]lid["][:]([^}]*)[}][,]/).flatten
      end

      def activity_data(activity, activity_index)
        name = activity.scan(/[,][\\]?["]name[\\]?["][:][\\]?["]([^\\"]*)[\\]?["][,]/).flatten.first
        lat = activity.scan(/[,][\\]?["]lat[\\]?["][:](.*?)(?:[,]|\Z)/).flatten.first
        lon = activity.scan(/[,][\\]?["]lng[\\]?["][:](.*?)(?:[,]|\Z)/).flatten.first
        been = activity.scan(/[,][\\]?["]flags[\\]?["][:]\[[\\]?["](been)[\\]["]\][,]/).flatten.first
        if been
          then been == true
        end
        fave = activity.scan(/[,][\\]?["]flags[\\]?["][:]\[[\\]?["](fave)[\\]["]\][,]/).flatten.first
        {
          place:{
            name: name,
            lat: lat,
            lon: lon,
            # what for been/favorite? is been a true/false? may not be our user's page... may be someone else's?
            # more broadly, do we want non-place/venue data? probably, but how to manage lat/lon?x
          },
        }
      end

      # OPERATIONS

    end
  end
end