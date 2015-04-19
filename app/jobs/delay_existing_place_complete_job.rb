class DelayExistingPlaceCompleteJob < ActiveJob::Base
  queue_as :completer

  def perform(place_id)
    Completers::ExistingPlaceCompleter.new( Place.find(place_id) ).complete!(delay: false)
  end
end