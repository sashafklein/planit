class TearOutOldStuff < ActiveRecord::Migration
  def change
    drop_table :days
    drop_table :legs
    drop_table :tags
    drop_table :taggings

    remove_column :items, :day_id
    remove_column :items, :order
  end
end
