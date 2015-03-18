module MarkMod
  class Query

    delegate :names, :locality, :region, :street_address, :country, :subregion, :sublocality, :lat, :lon, 
             to: :info
    attr_reader :info
    def initialize(mark)
      @info = mark.flags.named("Original Attrs").first.try(:info)
    end

    def exists?
      @info
    end

    def nearby
      @info.nearby || generated_nearby || latlon
    end

    def name
      names.first
    end

    def street_address
      street_addresses.first
    end

    private

    def latlon
      to_string([:lat, :lon])
    end

    def generated_nearby
      to_string([:sublocality, :locality, :subregion, :region, :country])
    end

    def to_string(vals)
      val = vals.map{ |att| @info[att] }.reject(&:blank?).join(", ")
      val.present? ? val : nil
    end
  end
end