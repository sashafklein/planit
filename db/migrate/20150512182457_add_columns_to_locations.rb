class AddColumnsToLocations < ActiveRecord::Migration
  def up
    add_column :locations, :name, :string
    add_column :locations, :country_id, :string
    add_column :locations, :admin_id_1, :string
    add_column :locations, :admin_id_2, :string
    add_column :locations, :admin_name_2, :string
    add_column :locations, :time_zone_id, :string
    add_column :locations, :fcode, :string
    remove_column :locations, :fcl_name

    Location.find_each do |l|
      response = HTTParty.get Location.geonames_url( l.geoname_id )
      l.update_attributes! Location.location_data(response)
      l.build_out_location_hierarchy
    end
  end

  def down
    add_column :locations, :fcl_name
    remove_column :locations, :name
    remove_column :locations, :country_id
    remove_column :locations, :admin_id_1
    remove_column :locations, :admin_id_2
    remove_column :locations, :admin_name_2
    remove_column :locations, :time_zone_id
    remove_column :locations, :fcode
  end

end
