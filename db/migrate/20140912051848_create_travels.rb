class CreateTravels < ActiveRecord::Migration
  def change
    create_table :travels do |t|
      t.string :mode
      t.integer :from_id
      t.integer :to_id
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
    add_index :travels, :from_id
    add_index :travels, :to_id
    add_index :travels, :next_step_id
  end
end
