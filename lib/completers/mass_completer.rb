module Completers
  class MassCompleter

    attr_accessor :scraped_hashes, :user, :url
    def initialize(scraped_hashes, user, url)
      @scraped_hashes, @user, @url = scraped_hashes.map(&:recursive_symbolize_keys!), user, url
    end

    def complete!
      completers.map(&:complete!).compact
    end

    def delay_complete!(delay=true)
      if delay
        completers.map(&:delay_complete!)
      else
        completers.map(&:complete!)
      end
    end

    private

    def completers
      @completers ||= @scraped_hashes.map{ |item_hash| Completer.new(item_hash, user, url) }
    end
  end
end