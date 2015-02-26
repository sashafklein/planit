class DelayCompleteJob < ActiveJob::Base
  queue_as :completer

  def perform(completer)
    completer.complete!
  end
end