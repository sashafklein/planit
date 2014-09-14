class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.integer :leg_id
      t.integer :day_id
      t.integer :location_id
      t.integer :order
      t.string  :mark
      t.string :category
      t.string :source
      t.string :source_url
      t.boolean :lodging
      t.boolean :meal
      t.text :notes
      t.integer :arrival_id
      t.integer :departure_id
      t.boolean :show_tab

      t.timestamps
    end
    add_index :items, :leg_id
    add_index :items, :day_id
    add_index :items, :location_id
    add_index :items, :arrival_id
    add_index :items, :departure_id
    add_index :items, :order
  end
end
