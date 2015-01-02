module Completers
  class Completer

    attr_accessor :user, :attrs, :decremented_attrs
    def initialize(attrs, user)
      @attrs, @user = attrs.recursive_symbolize_keys!, user
      @decremented_attrs = @attrs.dup
    end

    def complete!
      place = PlaceCompleter.new( decremented_attrs.delete(:place) ).complete!

      return nil unless place
      
      mark = user.marks.where(place_id: place.id).first_or_initialize
      mark.save!
      merge_and_create_associations!(mark)
      mark
    end

    def delay_complete!
      Delayed::Job.enqueue CompleterDelayer.new(self)
    end

    private

    def merge_and_create_associations!(mark)
      plan = create_plan!
      leg = create_leg!(plan)
      day = create_day!(plan, leg)
      item = create_item!(plan, day, mark)
    end

    def create_plan!
      return unless attrs[:item] || attrs[:plan] || attrs[:day]
      plan_attrs = decremented_attrs.delete(:plan) || {}
      
      name = plan_attrs[:name] || 'Untitled Trip'
      plan = user.plans.where(name: name).first_or_create!
    end

    def create_leg!(plan)
      return nil unless plan

      leg_attrs = decremented_attrs.delete(:leg) || {}
      name = leg_attrs.fetch(:name, '')
      optional_leg_attributes = leg_attrs.fetch(:order, {})
      plan.legs.where(name: name).first_or_create!(optional_leg_attributes)
    end

    def create_day!(plan, leg)
      return nil unless plan && leg && day_attrs = decremented_attrs.delete(:day)
      
      plan.days.where(leg_id: leg.id, order: day_attrs[:order]).first_or_create!
    end

    def create_item!(plan, day, mark)
      return nil unless plan 

      item_attrs = normalize_item_attrs(decremented_attrs.delete(:item) || {})

      search_attrs = { mark_id: mark.id, plan_id: plan.id }.merge item_attrs.slice(*Item.attribute_keys)
      search_attrs = search_attrs.merge(day_id: day.id) if day
      search_attrs[:day_of_week] = Item.day_of_weeks[search_attrs[:day_of_week].downcase] if search_attrs[:day_of_week]
      search_attrs[:start_time] = MilitaryTime.new(search_attrs[:start_time]).convert if search_attrs[:start_time]
      extra = search_attrs.delete(:extra)

      Item.where(search_attrs).first_or_create!(extra: extra || {})
    end

    def unacceptable_attributes(hash)
      hash.stringify_keys.keys - acceptable_keys
    end

    def acceptable_keys
      Place.column_names + Mark.column_names
    end

    def normalize_item_attrs(attrs)
      attrs[:extra] ||= {}
      attrs.except(*Item.attribute_keys).each do |key, value|
        attrs[:extra][key] = attrs.delete(key)
      end
      attrs
    end
  end
end