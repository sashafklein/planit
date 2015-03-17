class CreateShares < ActiveRecord::Migration
  def change
    create_table :shares do |t|
      t.references :object, polymorphic: true, index: true
      t.text :notes
      t.integer :sharer_id
      t.integer :sharee_id
      t.string :url
      t.boolean :viewed, default: false
      t.boolean :accepted, default: false

      t.timestamps null: false
    end
    add_index :shares, :sharer_id
    add_index :shares, :sharee_id
  end
end
