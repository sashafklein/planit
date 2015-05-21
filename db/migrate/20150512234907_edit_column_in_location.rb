class EditColumnInLocation < ActiveRecord::Migration
  def up
    add_column :locations, :continent, :string
    add_column :locations, :level, :integer

    Location.find_each do |location|
      if location.fcode == 'PCLI'
        response = HTTParty.get "http://api.geonames.org/getJSON?geonameId=#{ location.geoname_id }&username=planit&lang=en&type=json&style=full"
        location.update_attributes!( continent: get_continent( response['continentCode'] ), level: 0 )
      else
        location.update_attributes!( level: get_level( location.fcode ) )
      end
    end
  end

  def get_continent( continentCode )
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

  def get_level( fcode )
    case fcode
      when 'PCLI' then 0
      when 'ADM1' then 1
      when 'ADM2' then 2
      else 3
    end
  end

  def down
    remove_column :continent
    remove_column :level
  end
end
