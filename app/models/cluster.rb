class Cluster < BaseModel

  has_many :locations

  def self.suggested_collapsibles
    Cluster.where id: 
      self.all.select{ |c| 
        siblings = c.collapsible_with
        siblings.count>0 && siblings.map{ |sibling| sibling.rank }.all?{ |sibling_rank| sibling_rank < c.rank } ? collapsible = true : collapsible = false
        puts "#{c.name}: #{c.rank} (#{c.id})<= #{ siblings.map{ |s| [s.name, s.rank].join(': ') } }" if collapsible
        collapsible
      }.map{ |c| c.id }
  end

  def rename_and_absorb!( new_name )
    self.absorb_all_collapsible_clusters!
    self.update_attributes!( name: new_name ) if new_name
    return "#{self.name}: #{self.rank} (#{self.country_rank} in #{self.country.try(:name)})"
  end
  
  def location
    Location.find_by( geoname_id: geoname_id )
  end

  def country
    Location.where( geoname_id: country_id )
  end

  def country_rank
    Cluster.where( country_id: self.country_id ).order('rank DESC').map{ |c| c.id }.find_index( self.id )
  end

  def absorb_all_collapsible_clusters!( threshold: 25 )
    return unless collapsibles = collapsible_with( threshold: threshold )
    ActiveRecord::Base.transaction do
      Location.where( cluster_id: collapsibles.pluck( :id ) ).update_all( cluster_id: id )
      recalculate_rank!
      collapsibles.destroy_all
    end
    self
  end

  def collapsible_with( threshold: 25 )
    # return if self.divisible_into.present? # safety precaution to make sure that cocentric hierarchical admins don't get collapsed
    Cluster.where id: 
      Cluster.where( country_id: country_id )
        .where.not( id: id )
        .select{ |c| less_than_miles_from( threshold, c ) }
        .map{ |c| c.id }
  end

  def divisible_into    
    Cluster.where geoname_id: Location.where( country_id: country_id )
      .where.not( geoname_id: geoname_id )
      .where([ "admin_id_1 = :geoname_id or admin_id_2 = :geoname_id", { geoname_id: geoname_id.try( :to_s ) } ])
      .pluck( :geoname_id )
  end

  def recalculate_rank!
    marks_in_cluster = Mark.where( place_id: ObjectLocation.where( obj_type: "Place", location_id: locations.pluck(:id) ).pluck( :obj_id ) ).count
    update_attributes!( rank: marks_in_cluster )
  end

  def less_than_miles_from( max_distance, comparator )
    Distance.between_objects( self, comparator, rounding=1 ) < max_distance
  end

end