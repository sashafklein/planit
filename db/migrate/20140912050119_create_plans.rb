class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :title
      t.integer :user_id
      t.text :description
      t.integer :duration
      t.text :notes
      t.string :permission
      t.float :rating
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps
    end

    add_index :plans, :user_id
  end
end
