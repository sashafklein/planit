class Location < BaseModel
  has_many :location_searches
  has_many :users, through: :location_searches
  has_many :plans, through: :plan_locations
  has_many :plan_locations, dependent: :destroy

  def self.create_from_geonames!( response )
    create! location_data( response )
  end

  def self.location_data(response)
    timezone = response['timezone'] || {}
    {
      name: response['name'],
      ascii_name: response['asciiName'],
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
      geoname_id: response['geonameId']
    }
  end

  def self.geonames_url(geoname_id)
    "http://api.geonames.org/getJSON?geonameId=#{ geoname_id }&username=planit&lang=en&type=json&style=full"
  end

  def build_out_location_hierarchy
    %w( country_id admin_id_1 admin_id_2 ).each do |att|
      att_value = self[att]
      if att_value && !Location.find_by(geoname_id: att_value)
        response = HTTParty.get Location.geonames_url( att_value )
        Location.create_from_geonames!(response)
      end
    end
  end

end