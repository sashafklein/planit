class AddColumnSlugToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :slug, :string, null: false
    add_index :plans, :slug, unique: true
  end
end
