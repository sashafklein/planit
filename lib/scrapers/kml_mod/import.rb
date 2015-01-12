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
        plan_name = plan_name.gsub("Untitled layer", '')
        {
          plan:{
            name: plan_name,
          },
          scraper_url: @url, 
          # FILENAME
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
        if name && not_a_name = name.scan(/\A\s*((?:Placemark|Point)[ ]?\d*)\s*\Z/).flatten.first
          name = nil
        end
        latlon = activity.scan(/[<][Cc]oordinates[>](.*)[<][\/][Cc]oordinates[>]/).flatten
        lat = ''
        lon = ''
        if latlon && latlon.length == 1
          xyz = latlon.first.split(",")
          lat = xyz[1] # KML orients Longitude, Latitude, Altitude
          lon = xyz[0] # KML orients Longitude, Latitude, Altitude
          # Currently not capturing altidude, which would be xyz[2]
        end
        lat_in_name = name.scan(/#{lat.to_i}\.\d{2}\d*/).flatten.first unless !name
        lon_in_name = name.scan(/#{lon.to_i}\.\d{2}\d*/).flatten.first unless !name
        name = trim( name.gsub(/#{lat_in_name}/, '') ) unless !name
        name = trim( name.gsub(/#{lon_in_name}/, '') ) unless !name
        name = trim( name.scan(/(.*?)[:]?\Z/).flatten.first ) unless !name
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
            images:[{
              url: activity.scan(/[<](?:[Tt]ab_image|[Ii]mage|[Pp]hoto)[s]?[>](.*)[<][\/](?:[Tt]ab_image|[Ii]mage|[Pp]hoto)[s]?[>]/).flatten.first, 
              source: activity.scan(/[<](?:[Ii]mage_credit|[Ss]ource)[>](.*)[<][\/](?:[Ii]mage_credit|[Ss]ource)[>]/).flatten.first, 
              source_url: activity.scan(/[<][Ss]ource_url[>](.*)[<][\/][Ss]ource_url[>]/).flatten.first, 
            }],  
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