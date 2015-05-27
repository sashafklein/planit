class CreateOldLocations < ActiveRecord::Migration

  def change
    
    create_table :locations do |t|
      t.string :name
      t.string :local_name
      t.string :postal_code
      t.string :street_address
      t.string :cross_street
      t.string :phone
      t.string :country
      t.string :state
      t.string :city
      t.float :lat
      t.float :lon
      t.string :url
      t.string :genre
      t.string :subgenre

      t.timestamps
    end

  end

end