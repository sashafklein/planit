class TearOutOldStuff < ActiveRecord::Migration
  def up
    drop_table :days
    drop_table :legs
    drop_table :tags
    # drop_table :taggings

    remove_column :items, :day_id, :integer
    remove_column :items, :order, :integer
  end

  def down
    add_column :items, :day_id, :integer
    add_column :items, :order, :integer
  end
end
