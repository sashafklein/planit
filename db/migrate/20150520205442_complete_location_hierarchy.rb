class CompleteLocationHierarchy < ActiveRecord::Migration
  def up
    Location.find_each(&:build_out_location_hierarchy)
  end

  def down
    # Don't know which data to delete
  end
end
