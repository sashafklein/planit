class AddColumnFoursquareIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :foursquare_id, :string
  end
end
