class AddColumnFoursquareIconToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :foursquare_icon, :string
  end
end
