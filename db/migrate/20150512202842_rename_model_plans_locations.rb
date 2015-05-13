class RenameModelPlansLocations < ActiveRecord::Migration
  def up
    rename_table :plan_locations, :object_locations
    rename_column :object_locations, :plan_id, :obj_id
    add_column :object_locations, :obj_type, :string

    add_index :object_locations, :obj_type

    ObjectLocation.update_all({ obj_type: 'Plan' })
    Place.find_each do |place|
      place.get_place_geoname
    end
  end

  def down
    rename_table :object_locations, :plan_locations
    rename_column :plan_locations, :obj_id, :plan_id
    remove_column :plan_locations, :obj_type
  end
end
