module Completers
  class ApiCompleter::FoursquareRefine < ApiCompleter

    attr_accessor :fsid, :pip, :venue
    def initialize(pip)
      @pip, @fsid = pip, pip.foursquare_id
    end

    def complete
      return pip unless fsid.present?

      refine
      { place: pip, photos: venue.photos || [], success: true }
    rescue => e
      flag_failure(query: full_fs_url, response: @response, error: e)
      { place: pip, photos: venue.photos || [], success: false}
    end

    private

    def refine
      get_venue
      return unless venue.found?
      merge!
    end

    def get_venue
      @response = HTTParty.get(full_fs_url)
      @venue = ApiVenue::FoursquareRefineVenue.new @response
    end

    def merge!
      set_vals :menu, :mobile_menu, :wifi, :cross_street, :hours, :categories, :reservations, :reservations_link
    end

    def set_vals(*atts)
      atts.each{ |att| set_val( att, venue.send(att) ) }
    end

    def full_fs_url
      url = "#{ FoursquareExplore::FS_URL }/#{ fsid }?oauth_token=#{ FoursquareExplore.auth_token }"
      flag_query(url)
      url
    end

    def set_val(field, val, override=false)
      if !override && !pip.val(field) == false && pip.val(field).present?
        pip.flag( name: "Field Clash", details: "Ignored FoursquareRefine value.", info: { field: field, place: pip.val(field), venue: val} ) if pip.val(field) != val
      else
        pip.set_val field, val, self.class
      end
    end

  end
end