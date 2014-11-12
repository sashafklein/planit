class ChangeColumnStreetAddress < ActiveRecord::Migration
  def change
    add_column :places, :street_addresses, :string, array: true, default: []
    add_column :places, :full_address, :string
    Place.find_each{ |p| p.street_addresses = [p.street_address]; p.save! }
    remove_column :places, :street_address
  end
end
