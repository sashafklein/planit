class AddColumnSubregionToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :subregion, :string, default: nil
  end
end
