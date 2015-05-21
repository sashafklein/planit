class Plan < BaseModel

  belongs_to :user

  has_many :items, dependent: :destroy

  has_many_polymorphic table: :object_locations
  has_many :locations, through: :object_locations, as: :obj

  has_many :collaborations
  has_many :collaborators, through: :collaborations, source: :collaborator
  
  belongs_to :first_ancestor, class_name: 'Plan', foreign_key: 'first_ancestor_id'
  belongs_to :last_ancestor, class_name: 'Plan', foreign_key: 'last_ancestor_id'

  has_many_polymorphic table: :images, name: :imageable
  has_many_polymorphic table: :sources
  has_many_polymorphic table: :shares
  has_many_polymorphic table: :notes

  boolean_accessor :published
  json_accessor :manifest
  
  delegate :add_to_manifest, :remove_from_manifest, :move_in_manifest, to: :manifester

  def copy!(new_user:, copy_manifest: false)
    Plan.transaction do 
      new_plan = dup_without_relations!( keep: [:place_id, :first_ancestor_id], exclude: [(copy_manifest ? nil : :manifest), :last_ancestor_copied_at].compact, override: { user: new_user, name: "Copy of '#{name}'#{ user ? ' by ' + user.name : ''}" } ) 
      new_plan.update_attributes!( last_ancestor_id: id, last_ancestor_copied_at: Time.now, first_ancestor_id: self.first_ancestor_id || id, first_ancestor_copied_at: self.first_ancestor_copied_at || Time.now )
      items.each { |old_item| old_item.copy!(new_plan: new_plan) }
      new_plan
    end
  end

  def manifester
    PlanMod::Manifester.new(self)
  end

  def add_item_from_place_data!(user, data)
    return unless place = Place.find_or_initialize(data)
    marks_for_place_on_plan = Mark.unscoped.where(id: items.pluck(:mark_id), place_id: place.id)
    return marks_for_place_on_plan.items.first if marks_for_place_on_plan.try( :items ).present?

    place = place.validate_and_save!( data[:images] || [] ) unless place.persisted?
    place.background_complete!

    add_with_place!(user, place)
  end

  def add_items!(external_items)
    external_items.includes(:notes, mark: [:place, :notes]).each do |item|
      mark = Mark.unscoped.where( user_id: user.id, place_id: item.mark.place.id).first_or_create!
      new_item = mark.items.where(plan_id: id).first_or_create!
      
      mark_note = item.mark.notes.first
      item_note = item.notes.first 
      
      mark.notes.create!(body: mark_note.body, source: mark_note.source) if mark_note
      new_item.notes.create!(body: item_note.body, source: item_note.source) if item_note

      new_item
    end
  end

  def add_with_place!(user, place)
    mark = Mark.unscoped.where(user: user, place_id: place.id).first_or_initialize
    mark.update_attributes!(deleted: false)
    add_with_mark!(mark)
  end

  def add_with_mark!(mark)
    items.where(mark_id: mark.id).first_or_create!
  end

  def source
    sources.first
  end

  def best_image
    image = images.first || Image.where(imageable_type: 'Place', imageable_id: items.with_places.marks.places.pluck(:id)).first
  end

  def has_lodging?
    items.marks.where(lodging: true).any?
  end

  def uniq_abbreviated_coords(round=1)
    items.with_places.places.map{ |p| [ p.lat.round(1), p.lon.round(1) ] }.uniq
  end

  def coordinates
    items.with_places.coordinates
  end

  def maptype
    '' #todo
  end

  def bucket
    Item.where(day_id: nil, plan_id: self.id)
  end

  def places
    items.marks.with_places.places
  end

  def self.create_new!(user, plan_name, place_ids)
    plan = Plan.create!( user_id: user.id, name: plan_name )
    places = Place.where( id: place_ids )
    places.each do |place|
      mark = Mark.unscoped.where( user_id: user.id, place_id: place.id ).first_or_initialize
      mark.deleted = false
      mark.save!
      item = mark.items.where( plan_id: plan.id ).create!
    end
    return plan
  end

  def remove_all_traces!
    items.marks.places.destroy_all
    items.marks.destroy_all
    destroy
  end

  def add_nearby( data, user )
    location = Location.where( { geoname_id: data['geonameId'] } ).first_or_create( { ascii_name: data['asciiName'], admin_name_1: data['adminName1'], country_name: data['countryName'], fcode: data['fcode'], lat: data['lat'], lon: data['lon'] } )
    self.update_attributes!( latest_location_id: location.id ) if user_id == user.id
    ObjectLocation.where( obj: self, location_id: location.id ).first_or_create if user_id == user.id
    LocationSearch.create( location_id: location.id, user_id: user.id, success_terms: data['searchStrings'] ) if data['searchStrings'].present?
    return location
  end

end
