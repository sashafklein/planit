class RenameFieldsOnPlaceAndPlan < ActiveRecord::Migration
  def change
    rename_column :plans, :title, :name
    rename_column :places, :url, :website
  end
end
