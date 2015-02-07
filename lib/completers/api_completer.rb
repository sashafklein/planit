Dir["./api_venue/*.rb"].each {|file| require_relative file }

module Completers
  class ApiCompleter

    private 

    def flag_failure(query: 'unknown', response: {}, error:, extra: {})
      pip.flag( name: "API Failure", details: "#{self.class.to_s.demodulize} response unexpected", info: { error: error, query: query, place: pip.clean_attrs, response: response }.merge(extra) )
    end

    def flag_query(url)
      pip.flag(name: "API Query", details: "In #{self.class.to_s.demodulize}", info: { query: url })
    end
  end
end