Dir["./api_venue/*.rb"].each {|file| require_relative file }

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
      pip.flag( name: "Field Clash", details: "Ignored #{class_name} value.", info: { field: field, place_val: pip.val(field), venue_val: val} ) if pip.val(field) != val
    end

    def class_name
      self.class.to_s.demodulize
    end

    def set_val(field, val, override=false, allow_array_and_hash=true)
      if pip.val(field).is_defined? && ( !allow_array_and_hash && [Hash, Array].include?( pip.val(field).class ) )
        flag_field_clash(field, val)
      else
        pip.set_val field, val, self.class
      end
    end
  end
end