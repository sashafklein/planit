class CreatePlanLocations < ActiveRecord::Migration
  def change
    create_table :plan_locations do |t|
      t.integer :location_id, null: false
      t.integer :plan_id, null: false

      t.timestamps null: false
    end
    add_index :plan_locations, :location_id
    add_index :plan_locations, :plan_id
  end
end