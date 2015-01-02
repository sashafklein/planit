class ChangeArrayColumnsToText < ActiveRecord::Migration
  def change
    change_column :places, :flags, :text, array: true, default: []
    change_column :places, :completion_steps, :text, array: true, default: []
    change_column :places, :sublocality, :text
  end
end
