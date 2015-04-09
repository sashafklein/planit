class AddColumnFoursquareAccessTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :foursquare_access_token, :string
  end
end
