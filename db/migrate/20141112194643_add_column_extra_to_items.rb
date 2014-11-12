class AddColumnExtraToItems < ActiveRecord::Migration
  def change
    add_column :items, :extra, :hstore, default: {}
  end
end
