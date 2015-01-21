class AddPublishedToItemsMarksPlans < ActiveRecord::Migration
  def change
    add_column :plans, :published, :boolean, default: true
    add_column :items, :published, :boolean, default: true
    add_column :marks, :published, :boolean, default: true
  end
end
