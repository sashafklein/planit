module Completers
  class ApiVenue::VenueMatch

    extend Memoist
    delegate :name, :street_address, :full_address, :phone, :website, :ll_fit, :lat, :lon, to: :venue

    attr_accessor :pip, :venue, :stringent
    def initialize(pip:, venue:, stringent: true)
      @pip, @venue, @stringent = pip, venue, stringent
    end

    def match?
      name_match? || phone_match? || website_match? || address_match? || fancy_name_match?
    end

    def name_stringency
      return 2 if ll_fit(pip) < 1 # Reject distant, even if name matches
      case ll_fit(pip)
        when 1 then 0.99
        when 2 then 0.85
        when 3 then 0.75
        else 0.65
      end 
    end

    def ll_fit
      return 0 unless lat && lon
      return ( stringent ? 3 : 0 ) if pip.lat.nil? || pip.lon.nil?
      ((pip.lat.points_of_similarity(lat) + pip.lon.points_of_similarity(lon)) / 2.0).floor
    end

    private

    def name_match?
      pip.names.any? do |pip_name|
        Services::StringMatch.new(pip_name, name).bidirectional_value > name_stringency
      end
    end

    def address_match?
      ( street_address.present? && street_address == pip.street_address ) ||
        ( full_address.present? && respond_to?(full_address) && full_address == pip.full_address )
    end

    def phone_match?
      return false unless really_close?
      pip.phone.present? && phone.present? && pip.phone == phone.to_s.gsub(/\D/, '')
    end

    def website_match?
      return false unless really_close?
      pip.website.present? && website.present? && pip.website == website.to_s
    end

    def fancy_name_match?
      return false unless really_close? && pip_name = pip.name.downcase.without_articles
      return false unless pip_name.include?( trimmed_and_downcased = name.to_s.without_articles.downcase )
      return false unless ( rest_of_name = pip_name.gsub( trimmed_and_downcased, '' ).strip ).present?

      [:nearby, :locality, :sublocality, :street_address, :full_address].any? do |sym|
        pip.send(sym).to_s.downcase.include? rest_of_name
      end
    end

    def really_close?
      name_stringency >= 0.75
    end

    memoize :ll_fit, :fancy_name_match?, :address_match?, :name_match?, :match?
  end
end