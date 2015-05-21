class ImportAllGeonamesCountries < ActiveRecord::Migration

  def up
    res = HTTParty.get "http://api.geonames.org/searchJSON?featureCode=PCLI&username=planit&lang=en&type=json&style=full"
    res['geonames'].each do |country|
      Location.where( geoname_id: country['geonameId'] ).first_or_create({
        name: country['name'],
        ascii_name: country['asciiName'],
        lat: country['lat'],
        lon: country['lng'],
        country_name: country['countryName'],
        country_id: country['countryId'],
        fcode: country['fcode'],
        time_zone_id: time_zone_id( country['timezone'] ),
        continent: continent( country['continentCode'] )
      })
    end
  end

  def down    
  end

  def time_zone_id( hash )
    if hash
      hash['timeZoneId'] 
    else
      ""
    end
  end

  def continent( code )
    case code
      when "AF" then "Africa"
      when "NA" then "North America"
      when "SA" then "South America"
      when "EU" then "Europe"
      when "OC" then "Oceania"
      when "AS" then "Asia"
      when "AN" then "Antarctica"
    end
  end

end
