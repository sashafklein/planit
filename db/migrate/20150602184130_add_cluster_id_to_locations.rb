class AddClusterIdToLocations < ActiveRecord::Migration
  def up
    add_column :locations, :cluster_id, :integer, null: false, default: 0
    add_index :locations, :cluster_id
  end

  def down
    remove_column :locations, :cluster_id
  end
end
