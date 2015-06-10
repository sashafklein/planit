class SetClustersForLocations < ActiveRecord::Migration
  def up
    Location.find_each do |l|
      puts l
      LocationMod::Clusterer.new( l ).create_cluster!
    end
    Cluster.find_each do |c|
      c.recalculate_rank!
    end
  end

  def down
    Cluster.destroy_all
    Location.update_all( cluster_id: 0 )
  end
end
