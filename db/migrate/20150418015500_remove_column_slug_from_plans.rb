class RemoveColumnSlugFromPlans < ActiveRecord::Migration
  def change
    remove_column :plans, :slug
  end
end
