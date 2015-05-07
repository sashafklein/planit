class AddColumnsToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :first_ancestor_id, :integer
    add_index :plans, :first_ancestor_id
    add_column :plans, :last_ancestor_id, :integer
    add_index :plans, :last_ancestor_id
    add_column :plans, :first_ancestor_copied_at, :datetime
    add_column :plans, :last_ancestor_copied_at, :datetime

    Plan.find_each do |p|
      next unless p.name.include?("Copy of '")
      original_name = p.name.split("Copy of '").last.split(/(?:\' by)|(?:\'$)/).first
      if original = Plan.order('created_at ASC').find_by(name: original_name)
        p.update_attributes!(first_ancestor_id: original.id, first_ancestor_copied_at: Time.now, last_ancestor_id: original.id, last_ancestor_copied_at: Time.now)
      end
    end
  end
end
