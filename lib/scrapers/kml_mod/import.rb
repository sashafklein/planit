module Scrapers
  module KmlMod

    # PAGE SETUP

    class Import < Kml

      def initialize(url, page)
        super(url, page)
      end

      def itinerary_group
        itineraries = page.inner_html.split(/[<][Ff]older[>]/) unless !page
        if itineraries && itineraries.length == 1
          return itineraries
        else
          itineraries.shift
          return itineraries
        end
      end

      def itinerary_data(itinerary, itinerary_index)
        @folder_meta = itinerary.split(/[<][Pp]lacemark[>]/).flatten.first unless !itinerary
        plan_name = @folder_meta.scan(/[<][Nn]ame[>](.*)[<]\/[Nn]ame[>]/).flatten.first
        {
          plan:{
            name: plan_name,
          },
        }
      end

      def leg_group(itinerary)
        [itinerary.gsub(/#{@folder_meta}/, '')] unless !itinerary.present?
      end

      def day_group(leg)
        [leg]
      end

      def section_group(day)
        [day]
      end

      def activity_group(section)
        activities = section.split(/[<][Pp]lacemark[>]/) unless !section
        if activities && activities.length == 1
          return activities
        elsif activities
          activities.shift
          return activities
        end
        return []
      end

      def activity_data(activity, activity_index)
        name = activity.scan(/[<][Nn]ame[>](.*)[<][\/][Nn]ame[>]/).flatten.first
        if not_a_name = name.scan(/Placemark[ ]?\d*/).flatten.first
          name = nil
        end
        latlon = activity.scan(/[<][Cc]oordinates[>](.*)[<][\/][Cc]oordinates[>]/).flatten
        lat = ''
        lon = ''
        if latlon && latlon.length == 1
          lat = latlon.first.split(',').first
          lon = latlon.first.split(',').last
        end
        {
          place:{
            name: name,
            lat: lat,
            lon: lon,
            notes: activity.scan(/[<][Dd]escription[>](.*)[<][\/][Dd]escription[>]/).flatten.first,
            street_address: activity.scan(/[<][Ss]treet(?:[_]a|a|A)ddress[>](.*)[<][\/][Ss]treet(?:[_]a|a|A)ddress[>]/).flatten.first,
            locality: activity.scan(/[<](?:[Ll]ocality|[Cc]ity)[>](.*)[<][\/](?:[Ll]ocality|[Cc]ity)[>]/).flatten.first,
            region: activity.scan(/[<](?:[Rr]egion|[Ss]tate)[>](.*)[<][\/](?:[Rr]egion|[Ss]tate)[>]/).flatten.first,
            country: activity.scan(/[<][Cc]ountry[>](.*)[<][\/][Cc]ountry[>]/).flatten.first,
            postal_code: activity.scan(/[<](?:[Pp]ostal(?:[_]c|C|c)ode|[Zz]ip(?:[_]c|C|c)ode)[>](.*)[<][\/](?:[Pp]ostal(?:[_]c|C|c)ode|[Zz]ip(?:[_]c|C|c)ode)[>]/).flatten.first,
            phone: activity.scan(/[<][Pp]hone(?:[_]number|Number|number)?[>](.*)[<][\/][Pp]hone(?:[_]number|Number|number)?[>]/).flatten.first,
            website: activity.scan(/[<][Ww]ebsite[>](.*)[<][\/][Ww]ebsite[>]/).flatten.first,
            images:{
              url: activity.scan(/[<](?:[Tt]ab_image|[Ii]mage|[Pp]hoto)[s]?[>](.*)[<][\/](?:[Tt]ab_image|[Ii]mage|[Pp]hoto)[s]?[>]/).flatten.first, 
              source: activity.scan(/[<][Ii]mage_credit[>](.*)[<][\/][Ii]mage_credit[>]/).flatten.first, 
              source_url: activity.scan(/[<][Ss]ource_url[>](.*)[<][\/][Ss]ource_url[>]/).flatten.first, 
            },  
          },
          item:{
            day: activity.scan(/[<][Dd]ay[>](.*)[<][\/][Dd]ay/).flatten.first, 
            meal: activity.scan(/[<][Mm]eal[>](.*)[<][\/][Mm]eal/).flatten.first, 
          },  
        }
        # is it OK if we don't have a name associated with the lat/lon?  if name == nil, super-high accuracy on lat/lon?  ask/flag for user review?
        # what should we do if it's a multi-point/coordinates pin?
      end

    end
  end
end