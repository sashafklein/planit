class CreateLegs < ActiveRecord::Migration
  def change
    create_table :legs do |t|
      t.string :name
      t.integer :order
      t.boolean :bucket, default: false
      t.text :notes
      t.integer :plan_id

      t.timestamps
    end

    add_index :legs, :plan_id
  end
end
