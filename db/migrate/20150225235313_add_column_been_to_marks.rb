class AddColumnBeenToMarks < ActiveRecord::Migration
  def change
    add_column :marks, :been, :boolean, default: false
    add_column :marks, :loved, :boolean, default: false
    add_column :marks, :deleted, :boolean, default: false
  end
end
