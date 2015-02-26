class CreatePlaceOptions < ActiveRecord::Migration
  def change
    create_table :place_options do |t|
      
      t.integer :price_tier
      t.integer :feature_type
      t.integer :mark_id
      t.float :lat
      t.float :lon
      t.boolean :wifi, default: false
      t.boolean :reservations, default: false
      t.text :description
      t.text :sublocality
      t.text :completion_steps, array: true, default: []
      t.string :street_addresses, array: true, default: []
      t.string :names, array: true, default: []
      t.string :meta_categories, array: true, default: []
      t.string :categories, array: true, default: []
      t.string :phones, array: true, default: []
      t.string :full_address
      t.string :subregion
      t.string :menu
      t.string :mobile_menu
      t.string :foursquare_id
      t.string :scrape_url
      t.string :timezone_string
      t.string :reservations_link
      t.string :website
      t.string :email
      t.string :contact_name
      t.string :postal_code
      t.string :cross_street
      t.string :country
      t.string :region
      t.string :locality
      t.string :price_note
      t.json :extra, default: {}
      t.json :hours, default: {}

      t.timestamps null: false
    end

    add_index :place_options, :mark_id
  end

  def down
    drop_table :place_options
  end
end
