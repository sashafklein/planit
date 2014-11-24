module Services
  class CompleterDelayer
    def initialize(completer)
      @completer = completer
    end

    def perform
      @completer.complete!
    end
  end
end