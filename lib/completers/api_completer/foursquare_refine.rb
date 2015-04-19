module Completers
  class ApiCompleter::FoursquareRefine < ApiCompleter

    attr_accessor :fsid, :pip, :venue
    def initialize(pip, attrs={}, take: nil)
      @pip, @fsid = pip, pip.foursquare_id
    end

    def complete
      return pip unless fsid.present?

      refine
      { place: pip || [], success: true }
    rescue => e
      flag_failure(query: full_fs_url, response: @response, error: e)
      { place: pip || [], success: false}
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

    def atts_to_merge
      [:menu, :mobile_menu, :wifi, :cross_street, :hours, :categories, :reservations, :reservations_link, :photos, :street_addresses]
    end

    def full_fs_url
      url = "#{ FoursquareExplore::FS_URL }/#{ fsid }?#{ FoursquareExplore.auth }"
      flag_query(url)
      url
    end

  end
end