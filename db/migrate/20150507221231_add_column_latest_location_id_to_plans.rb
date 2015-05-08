class AddColumnLatestLocationIdToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :latest_location_id, :integer
    add_index :plans, :latest_location_id
  end
end
