Dir["./api_venue/*.rb"].each { |file| require_relative file }

module Completers
  class ApiCompleter

    private 

    def flag_failure(query: 'unknown', response: {}, error:, extra: {})
      pip.flag( name: "API Failure", details: "#{class_name} response unexpected", info: { error: error, query: query, place: pip.clean_attrs, response: response }.merge(extra) )
    end

    def flag_query(url)
      pip.flag(name: "API Query", details: "In #{class_name}", info: { query: url })
    end

    def flag_field_clash(field, val)
      pip.flag( name: "Field Clash", details: "Ignored #{class_name} value.", info: { field: field, place_val: pip.val(field), venue_val: val } ) if pip.val(field) != val
    end

    def venue_failure
      pip.flag( name: "Pick Venue Failure", details: "Couldn't pick an acceptable #{class_name} venue", info: { pip: pip.clean_attrs, venues: @venues } )
    end

    def class_name
      self.class.to_s.demodulize
    end

    def merge!
      if pip.unsure.include?(class_name)
        venues.each_with_index do |venue, i|
          pip.set_ds("#{class_name.underscore}#{i}")
          set_vals(fields: atts_to_merge, v: venue)
        end
        pip.set_ds(:base)
      else
        set_vals(fields: atts_to_merge)
      end
    end

    def set_val(field:, val:, hierarchy_bump: 0, allow_a_or_h: true, block_non_latinate: false)
      pip_val = pip.val(field)

      if field == :photos && val.present?
        add_photos(val)
      elsif dont_override?(pip_val, allow_a_or_h)
        flag_field_clash(field, val)
      elsif block_non_latinate && pip.val(field) && pip.val(field).is_a?(String) && pip.val(field).latinate? && val.present? && val.non_latinate?
        flag_field_clash(field, val)
      else
        pip.set_val( field: field, val: val, source: class_name, hierarchy_bump: hierarchy_bump )
      end
    end

    def set_vals(fields:, h_bump: 0, allow_a_or_h: true, v: venue, block_non_latinate: false)
      fields.each{ |field| set_val(field: field, val: v.send(field), hierarchy_bump: h_bump, allow_a_or_h: allow_a_or_h, block_non_latinate: block_non_latinate) }
    end

    def pick_venue
      ok_lls = venues.select{ |v| v.matcher(pip).ll_fit >= 2 }

      @venue = ok_lls.find do |v| 
        v.venue_match?(pip) && ( v.seems_legit? if v.respond_to?(:seems_legit?) )
      end
      
      venue_failure unless @venue
      pip.unsure << class_name if @venue != ok_lls.first
    rescue => e
      venue_failure
    end

    def dont_override?(pip_val, allow_a_or_h)
      pip_val.is_defined? && ( !allow_a_or_h && pip_val.is_a_or_h? )
    end

    def triangulate_from_previous!
      previous = pip.previous(class_name).select{ |n| pip.unsure.include?(n) }
      previous.any?{ |completer_name| load_previous_if_matching!(completer_name) }
    end

    def load_previous_if_matching!(completer_name)
      return false unless ( matches = pip.viable_datastores(type_name: completer_name, venue: venue) ).any?

      if matches.count > 1
        pip.flag(name: "More than one triangulation match", details: "#{class_name} triangulating against #{completer_name} results", info: { current: venue.serialize, matches: matches.map(&:clean_attrs) } )
      else
        pip.flag(name: "Triangulated to confirm venue", details: "#{class_name} triangulated against #{completer_name} results", info: { current: venue.serialize, match: matches.first.clean_attrs } )
      end

      pip.triangulated = true
      pip.load_and_flush_siblings!( matches.first )
      set_val field: :completion_steps, val: pip.unsure.delete(completer_name)
    end

    def add_photos(val)
      if val.is_a?(Hash)
        array, source = val[:photos], val[:source]
      else
        array, source = val, class_name
      end
      pip.add_photos array.map{ |p| Image.where(url: p).first_or_initialize(source: source) }
    end
  end
end