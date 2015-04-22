class Plan < BaseModel

  belongs_to :user

  has_many :legs
  has_many :days, through: :legs
  has_many :items, dependent: :destroy
  
  has_many_polymorphic table: :images, name: :imageable
  has_many_polymorphic table: :sources
  has_many_polymorphic table: :shares
  has_many_polymorphic table: :notes

  boolean_accessor :published
  json_accessor :manifest
  delegate :last_day, :departure, to: :last_leg
  delegate :arrival, to: :first_leg
  delegate :add_to_manifest, :remove_from_manifest, :move_in_manifest, to: :manifester

  def copy!(new_user:, copy_manifest: false)
    Plan.transaction do 
      new_plan = dup_without_relations!( keep: [:place_id], exclude: [(copy_manifest ? nil : :manifest)].compact, override: { user: new_user, name: "Copy of '#{name}'#{ user ? ' by ' + user.name : ''}" } ) 
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
    images.first || Image.where(imageable_type: 'Place', imageable_id: items.with_places.marks.places.pluck(:id)).first
  end

  def has_lodging?
    items.marks.where(lodging: true).any?
  end

  def first_leg
    legs.first
  end

  def last_leg
    legs.last
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

  def total_days
    days.count
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

end
