class AddDefaultsToPlaceHstores < ActiveRecord::Migration
  def change
    change_column :places, :phones, :hstore, default: {}
    change_column :places, :extra, :hstore, default: {}
    change_column :places, :hours, :hstore, default: {}
    change_column :places, :names, :string, array: true, default: []
  end
end
