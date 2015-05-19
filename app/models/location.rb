class Location < BaseModel
  has_many :location_searches
  has_many :users, through: :location_searches
  has_many :object_locations, dependent: :destroy
  has_many :plans, through: :object_locations, source: :obj, source_type: 'Plan'
  has_many :places, through: :object_locations, source: :obj, source_type: 'Place'

  def self.create_from_geonames!( response )
    create! location_data( response )
  end

  def self.location_data( response )
    timezone = response['timezone'] || {}
    asciiname = response['asciiName'] || response['name'].no_accents
    {
      name: response['name'],
      ascii_name: asciiname,
      continent: get_continent( response['continentCode'] ),
      country_name: response['countryName'],
      country_id: response['countryId'],
      admin_name_1: response['adminName1'],
      admin_id_1: response['adminId1'],
      admin_name_2: response['adminName2'],
      admin_id_2: response['adminId2'],
      time_zone_id: timezone['timeZoneId'],
      lat: response['lat'],
      lon: response['lng'],
      fcode: response['fcode'],
      geoname_id: response['geonameId'],
      level: get_level(response['fcode'])
    }.slice( *Location.attribute_keys(reject_ids: false) )
  end

  def self.get_continent( continentCode )
    case continentCode
      when 'NA' then 'North America'
      when 'SA' then 'South America'
      when 'AN' then 'Antarctica'
      when 'EU' then 'Europe'
      when 'AF' then 'Africa'
      when 'AS' then 'Asia'
      when 'OC' then 'Oceania'
    end
  end

  def self.get_level(fcode)
    case fcode
      when 'PCLI' then 0
      when 'ADM1' then 1
      when 'ADM2' then 2
      else 3
    end
  end

  def self.geonames_url(geoname_id)
    "http://api.geonames.org/getJSON?geonameId=#{ geoname_id }&username=planit&lang=en&type=json&style=full"
  end

  def build_out_location_hierarchy
    %w( country_id admin_id_1 ).each do |att|
      att_value = self[att]
      if att_value && !Location.find_by(geoname_id: att_value)
        response = HTTParty.get Location.geonames_url( att_value )
        Location.create_from_geonames!(response)
      end
    end
    return self
  end

end