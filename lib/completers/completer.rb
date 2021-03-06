module Completers
  class Completer

    attr_accessor :user, :attrs, :decremented_attrs, :url
    def initialize(attrs, user, url=nil)
      @attrs, @user = attrs.recursive_symbolize_keys!, user
      @decremented_attrs = @attrs.dup
      @url = url || attrs[:scraper_url]
    end

    def complete!
      if url && !attrs[:item] && !attrs[:plan] && preexisting_source = Source.for_url( url ).find_by(obj_type: 'Mark')
        complete_from_preexisting!( preexisting_source )
      else
        complete_from_scratch!
      end
    end

    def delay_complete!
      DelayCompleteJob.perform_later(attrs, user, url)
    end

    private

    def complete_from_scratch!
      return unless response = PlaceCompleter.new( decremented_attrs.delete(:place), url ).complete!
      create_mark_and_associations!(
        place_hash:              ( response[:place] ? response : nil),
        place_option_hash:  ( response[:place_options] ? response : nil)
      )
    end

    def complete_from_preexisting!( preexisting_source )
      return complete_from_scratch! unless preexisting_mark = Mark.unscoped.where.not( place_id: nil ).find_by( id: preexisting_source.obj_id )
      user.marks.where( place_id: preexisting_mark.place.id ).first_or_initialize
      mark.save_with_source!(source_url: url)
    end

    def create_mark_and_associations!(place_hash:, place_option_hash:)
      raise "Mark needs either Place or PlaceOptions" if (place_hash.present? && place_option_hash.present?) || (!place_hash.present? && !place_option_hash.present?)

      mark = Mark.unscoped.where(place_id: place_hash[:place].id, user: user).first_or_initialize if place_hash
      mark ||= Mark.unscoped.where(user: user).with_original_query( place_option_hash[:attrs] ) if place_option_hash
      mark ||= user.marks.new

      mark = mark.save_with_source!(source_url: url)

      if place_option_hash
        place_option_hash[:place_options].each{ |po| po.update_attributes!(mark_id: mark.id) }
        mark.flags.create!(name: 'Original Attrs', info: place_option_hash[:attrs])
      end

      merge_and_create_associations!(mark, (place_hash || place_option_hash || {})[:notes] || [] )
      mark
    end

    def merge_and_create_associations!(mark, notes=[])
      plan = create_plan!(mark)
      item = create_item!(plan, mark)
      notes.each{ |n| mark.notes.where(body: n, source: mark.source).create! }
    end

    def create_plan!(mark)
      return unless attrs[:item] || attrs[:plan]
      plan_attrs = decremented_attrs.delete(:plan) || {}
      
      name = plan_attrs[:name] || 'Untitled Trip'
      plan = user.plans.where(name: name).first_or_create!

      create_plan_source(plan, mark.source) if mark.source
      plan
    end

    def create_item!(plan, mark)
      return nil unless plan 
      
      item_attrs = normalize_item_attrs(decremented_attrs.delete(:item) || {})

      search_attrs = { mark_id: mark.id, plan_id: plan.id }.merge item_attrs.slice(*Item.attribute_keys)
      # search_attrs[:start_time] = Services::TimeConverter.new(search_attrs[:start_time]).absolute if search_attrs[:start_time]
      extra = search_attrs.delete(:extra)

      item = Item.where(search_attrs).first_or_create!(extra: extra || {})
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

    def create_plan_source(plan, mark_source)
      plan.sources.where( mark_source.generic_attrs ).first_or_create
    end
  end
end