module Services
  class MassCompleter

    attr_accessor :items, :user
    def initialize(items, user)
      @items, @user = items, user
    end

    def completers
      @completers ||= @items.map { |i| Completer.new(i, user) }
    end

    def complete!
      completers.map(&:complete!)
    end
  end
end