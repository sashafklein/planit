module Completers
  class ApiVenue

    include MetaExt::ArrayAccessor 
    array_accessor :phone, :street_address, :name, :category, :meta_category, omit_scopes: true

    extend Memoist

    def serialize(extras=[])
      (Place.attribute_keys.concat(extras) ).inject({}) do |hash, k| 
        hash[k] = respond_to?(k) ? send(k) : nil
        hash
      end.compact
    end

    def self.venue_name
      to_s.demodulize.split("Venue").first
    end

    def venue_match?(pip, overwrite_nil: true)
      matcher(pip, overwrite_nil).match?  
    end

    def matcher(pip, overwrite_nil=true)
      VenueMatch.new(venue: self, pip: pip, stringent: overwrite_nil)
    end
  end
end