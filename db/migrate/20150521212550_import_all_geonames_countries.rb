class ImportAllGeonamesCountries < ActiveRecord::Migration

  def up
    res = HTTParty.get "http://api.geonames.org/searchJSON?featureCode=PCLI&username=planit&lang=en&type=json&style=full"
    res['geonames'].each do |country|
      data = Location.location_data( country )
      Location.where( geoname_id: country['geonameId'] ).first_or_create( data )
    end
  end

  def down    
  end

end
