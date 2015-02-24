class AddColumnFeatureTypeToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :feature_type, :integer, default: 0
  end
end
