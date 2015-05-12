class AddColumnsToLocations < ActiveRecord::Migration
  def up
    add_column :locations, :name, :string
    add_column :locations, :country_code, :string
    add_column :locations, :admin_code_1, :string
    add_column :locations, :admin_code_2, :string
    add_column :locations, :admin_name_2, :string
    add_column :locations, :time_zone_id, :string
    add_column :locations, :fcode, :string

    Location.find_each do |l|
      response = HTTParty.get "http://api.geonames.org/getJSON?geonameId=#{ l.geoname_id }&username=planit&lang=en&type=json&style=full"
      l.update_attributes!({
        name: response[:name],
        country_code: response[:countryCode],
        admin_code_1: response[:adminCode1],
        admin_code_2: response[:adminCode2],
        admin_name_2: response[:adminName2],
        time_zone_id: response[:timezone].try( :[], :timeZoneId ),
        fcode: response[:fcode]
      })
    end
  end

  def down
    remove_column :locations, :name
    remove_column :locations, :country_code
    remove_column :locations, :admin_code_1
    remove_column :locations, :admin_code_2
    remove_column :locations, :admin_name_2
    remove_column :locations, :time_zone_id
    remove_column :locations, :fcode
  end
end
