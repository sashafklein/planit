class CreateDays < ActiveRecord::Migration
  def change
    create_table :days do |t|
      t.integer :leg_id
      t.integer :order
      t.text :notes

      t.timestamps
    end
    add_index :days, :leg_id
  end
end
