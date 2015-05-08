class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :ascii_name, null: false
      t.string :admin_name_1
      t.string :country_name
      t.string :fcl_name
      t.integer :geoname_id, null: false
      t.float :lat, null: false
      t.float :lon, null: false

      t.timestamps null: false
    end

    add_index :locations, :geoname_id

    create_table :location_searches do |t|
      t.string :success_terms, array: true, default: [], limit: nil
      t.integer :location_id, null: false
      t.integer :user_id

      t.timestamps null: false
    end

    add_index :location_searches, :location_id

  end
end
