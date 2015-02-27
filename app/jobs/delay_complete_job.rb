class DelayCompleteJob < ActiveJob::Base
  queue_as :completer

  def perform(attrs, user, url)
    Completers::Completer.new(attrs, user, url).complete!
  end
end