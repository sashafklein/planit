class CreateTravels < ActiveRecord::Migration
  def change
    create_table :travels do |t|
      t.string :mode
      t.integer :origin_id
      t.integer :destination_id
      t.datetime :departs_at
      t.datetime :arrives_at
      t.string :vessel
      t.integer :next_step_id
      t.text :notes
      t.string :carrier
      t.string :departure_terminal
      t.string :arrival_terminal
      t.string :confirmation_code

      t.timestamps
    end
    add_index :travels, :origin_id
    add_index :travels, :destination_id
    add_index :travels, :next_step_id
  end
end
