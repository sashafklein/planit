class AddMetaCategoriesToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :meta_categories, :string, array: true, default: []
  end
end
