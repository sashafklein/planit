module Services
  class MassCompleter

    attr_accessor :scraped_hashes, :user
    def initialize(scraped_hashes, user)
      @scraped_hashes, @user = scraped_hashes.map(&:recursive_symbolize_keys!), user
    end

    def completers
      @completers ||= @scraped_hashes.map { |i| Completer.new(i, user) }
    end

    def complete!
      completers.map(&:complete!)
    end
  end
end