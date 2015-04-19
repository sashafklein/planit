module Completers
  class ExistingPlaceCompleter

    attr_accessor :place
    def initialize(place)
      @place = place
    end

    def complete!(delay: true)
      return delay_complete! if delay
      PlaceCompleter.new( place.atts_except(:created_at, :updated_at) ).complete!
    end

    private

    def delay_complete!
      DelayExistingPlaceCompleteJob.perform_later(place.id)
    end
  end
end