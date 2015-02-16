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
        venues.each_with_index do |v, i|
          pip.set_ds("#{class_name.underscore}#{i}")
          set_vals(fields: atts_to_merge, v: v)
        end
        pip.set_ds(:base)
      else
        set_vals(fields: atts_to_merge)
      end
    end

    def set_val(field:, val:, hierarchy_bump: 0, allow_a_or_h: true)
      pip_val = pip.val(field)
      if dont_override?(pip_val, allow_a_or_h)
        flag_field_clash(field, val)
      else
        pip.set_val( field: field, val: val, source: class_name, hierarchy_bump: hierarchy_bump )
      end
    end

    def set_vals(fields:, h_bump: 0, allow_a_or_h: true, v: venue)
      fields.each{ |field| set_val(field: field, val: v.send(field), hierarchy_bump: h_bump, allow_a_or_h: allow_a_or_h) }
    end

    def pick_venue
      ok_lls = venues.select{ |v| v.points_ll_similarity(pip) >= 2 }
      
      @venue = ok_lls.find do |v| 
        v.matching_ll_and_name_or_address(pip)
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
  end
end