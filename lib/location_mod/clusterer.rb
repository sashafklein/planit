module LocationMod
  class Clusterer

    extend Memoist
    
    attr_accessor :location
    def initialize(location)
      @location = location
    end

    def create_cluster!
      location.update_attributes!( cluster_id: cluster.id ) unless location.cluster || !cluster
    end

    def cluster
      location.cluster || find_or_create_locations_cluster_object
    end

    private

    def find_or_create_locations_cluster_object
      return unless found_cluster_info = extract_cluster_info_from_location
      location.reload if reset_country_id!
      cluster = Cluster.where( name: found_cluster_info[:name].no_accents, country_id: location.country_id, geoname_id: found_cluster_info[:geoname_id] ).first_or_create( lat: found_cluster_info[:lat], lon: found_cluster_info[:lon] )
      # puts "location_geoname=#{location.geoname_id}, cluster_geoname=#{found_cluster_info[:geoname_id]}, finalname=#{found_cluster_info[:name].no_accents}, country=#{location.country_name}, #{found_cluster_info[:lat]},#{found_cluster_info[:lon]}"
      return cluster
    end

    def extract_cluster_info_from_location
      if is_country = ( location.fcode == "PCLI" )
        extract_cluster_info_from_country
      elsif has_admin_2 = ( location.admin_id_2.present? && location.admin_name_2.present? )
        extract_cluster_info_from_admin_2
      else
        extract_cluster_info_from_geoname
      end
    end

    def extract_cluster_info_from_country # returns nil unless country is cluster-sized
      if location.country_id.present? && small_country_match = small_countries[ location.country_id.to_i ]
        country = fetch_location( location.country_id.to_i )
        { name: small_country_match, geoname_id: country.geoname_id, lat: country.lat, lon: country.lon }
      end
    end

    def extract_cluster_info_from_admin_2
      if admin_2_for_location && cluster = admin_2_for_location.cluster
        { name: cluster.name, geoname_id: cluster.geoname_id, lat: cluster.lat, lon: cluster.lon }
      elsif admin_2_for_location
        { name: admin_2_for_location.name, geoname_id: admin_2_for_location.geoname_id, lat: admin_2_for_location.lat, lon: admin_2_for_location.lon }
      end
    end

    def admin_2_for_location
      fetch_location( location.admin_id_2 ) if location.admin_id_2.present?
    end

    def extract_cluster_info_from_geoname
      extraction = nil
      %w( ADM2 PPLC PPLA ADM1 PPL PPLX ).each do |value|
        responses = geonames_find_nearby( location, value.chars.first )
        right_response = responses.find{ |r| r['fcode'] == value } if responses
        right_response ||= extract_cluster_info_from_admin_1 if value == "ADM1"
        extraction = right_response.present? ? { name: right_response['name'], geoname_id: (right_response['geonameId']||right_response['geoname_id']), lat: right_response['lat'], lon: (right_response['lng']||right_response['lon']) } : nil
        break if extraction.present?
      end
      extraction
    end

    def extract_cluster_info_from_admin_1
      admin_1 = fetch_location( location.admin_id_1.to_i ) if location.admin_id_1.present?
      admin_1 ? admin_1 : nil
    end

    def fetch_location( geoname_id )
      return unless geoname_id
      if location = Location.find_by( geoname_id: geoname_id )
        location
      else
        Location.create_from_geonames!( geonames_find_id( geoname_id ) )
      end
    end

    def geonames_find_nearby( location_to_query, feature_class )
      responses_with_header = HTTParty.get( "http://api.geonames.org/findNearbyJSON?radius=5&lat=#{ location_to_query.lat }&lng=#{ location_to_query.lon }&username=jauntful&lang=en&maxRows=50&style=full&featureClass=#{ feature_class }" )
      puts "http://api.geonames.org/findNearbyJSON?radius=5&lat=#{ location_to_query.lat }&lng=#{ location_to_query.lon }&username=jauntful&lang=en&maxRows=50&style=full&featureClass=#{ feature_class }"
      status = if responses_with_header then 'success' else 'failure' end 
      puts "#{ status }"
      responses = responses_with_header['geonames'] if responses_with_header
    end

    def geonames_find_id( geoname_id )
      response_with_header = HTTParty.get( "http://api.geonames.org/getJSON?geonameId=#{ location.country_id }&username=jauntful&lang=en&type=json&style=full" )
      puts "http://api.geonames.org/getJSON?geonameId=#{ location.country_id }&username=jauntful&lang=en&type=json&style=full"
      status = if response_with_header then 'success' else 'failure' end 
      puts "#{ status }"
      response = response_with_header['geonames'] if response_with_header
    end

    def small_countries
      yaml = YAML.load_file( File.join( Rails.root, "lib/directories/yml/small_countries.yml") )
      yaml.inject({}){ |h, e| h[e.keys.first] = e.values.first; h }
    end

    def reset_country_id!
      return false if location.country_id
      
      cid = Location.where( country_name: location.country_name ).where.not( country_id: nil ).first.try(:country_id)
      location.update_attributes(country_id: cid)
    end

    memoize :small_countries, :geonames_find_nearby, :geonames_find_id, :cluster
  end
end