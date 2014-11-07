module Services
  class Completer

    attr_accessor :user, :attrs, :decremented_attrs, :place
    def initialize(attrs, user)
      @attrs, @user, @decremented_attrs = attrs.symbolize_keys, user, attrs.symbolize_keys.dup
    end

    def complete!
      @place = PlaceFinder.new(decremented_attrs.delete(:place)).find!

      return nil unless place

      fs_complete!
      place.save! unless place.persisted?

      mark = user.marks.where(place_id: place.id).first_or_initialize
      merge_and_create_associations!(mark)
      mark
    end

    private

    def merge_and_create_associations!(mark)
      plan = create_plan!
      leg = create_leg!(plan)
      day = create_day!(plan, leg)
    end

    def create_plan!
      return nil unless plan_attrs = decremented_attrs.delete(:plan)
      
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
      return nil unless plan && item_attrs = decremented_attrs.delete(:item)

      search_attrs = { mark_id: mark.id, plan_id: plan.id }.merge item_attrs.slice(*Item.attribute_keys)
      search_attrs = search_attrs.merge(day_id: day.id) if day

      items = Item.where(search_attrs).first_or_create!
    end

    def no_val?(v)
      v.nil? || v == '' || v == []
    end

    def complete?
      Place.attribute_keys.all?{ |key| place.send(key).present? || key == false }
    end

    def fs_complete!
      if complete?
        @place
      else
        @place = Services::FourSquareCompleter.new(@place).complete!
        @place
      end
    end

    def unacceptable_attributes(hash)
      hash.stringify_keys.keys - acceptable_keys
    end

    def acceptable_keys
      Place.column_names + Mark.column_names
    end
  end
end