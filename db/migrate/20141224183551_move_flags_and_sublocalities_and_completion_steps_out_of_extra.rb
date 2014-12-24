class MoveFlagsAndSublocalitiesAndCompletionStepsOutOfExtra < ActiveRecord::Migration
  def change
    add_column :places, :flags, :string, array: true, default: []
    add_column :places, :completion_steps, :string, array: true, default: []
    add_column :places, :sublocality, :string
  end
end
