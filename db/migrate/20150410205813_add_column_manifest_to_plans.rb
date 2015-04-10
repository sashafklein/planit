class AddColumnManifestToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :manifest, :json, default: []
  end
end
