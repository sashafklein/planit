class RemoveDayOfWeekFromItems < ActiveRecord::Migration
  def change
    remove_column :items, :day_of_week, :integer
    remove_column :items, :duration, :float
  end
end
