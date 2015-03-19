class AddColumnPublishedToPlace < ActiveRecord::Migration
  def change
    add_column :places, :published, :boolean, default: :true
  end
end
