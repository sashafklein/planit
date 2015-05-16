class AddBookingDetailsToItems < ActiveRecord::Migration
  def change
    remove_column :items, :start_time, :string
    add_column :items, :start_time, :string
    add_column :items, :end_time, :string
    add_column :items, :start_date, :string
    add_column :items, :end_date, :string
    add_column :items, :confirmation, :string
  end
end
