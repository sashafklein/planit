module Completers
  class MassCompleter

    attr_accessor :scraped_hashes, :user, :url
    def initialize(scraped_hashes, user, url)
      @scraped_hashes, @user, @url = scraped_hashes.map(&:recursive_symbolize_keys!), user, url
    end

    def complete!
      if preexisting_plan = user.plans.where( id: Source.for_url( url ).where( obj_type: 'Plan' ).pluck(:obj_id) ).first
        return preexisting_plan.items.marks
      else
        completers.map(&:complete!).compact
      end
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