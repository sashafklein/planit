module Services
  class GoogleJsonParser

    extend Memoist

    include RegexLibrary
    extend RegexLibrary
    include UsualSuspects
    extend UsualSuspects
    include CssOperators
    extend CssOperators
    include ScraperOperators
    extend ScraperOperators
    include GeoQueries

    attr_reader :bsjson, :link, :text
    def initialize(link, text='')
      @link, @text = link, text
      @bsjson = open( URI.parse(link) ).read
    end

    def names
      [ unhex( trim( bsjson.scan(/infoWindow\:\{title:\"(.*?)\"/).flatten.first ) ), link_name ].compact.uniq
    end

    def full_address
      address_lines.gsub('","', ', ').gsub('"', '') if address_lines
    end

    def locality          
      bsjson.scan(/sxct\:\"(.*?)\"/).flatten.first
    end

    def region          
      bsjson.scan(/sxpr\:\"(.*?)\"/).flatten.first
    end

    def postal_code          
      bsjson.scan(/sxpo\:\"(.*?)\"/).flatten.first
    end

    def country          
      find_country_by_code(country_code) if country_code
    end

    def street_address
      trim_full_to_street_address(full_address, country, postal_code, region, locality, names.first)
    end

    def website          
      bsjson.scan(/actual_url\:\"(.*?)\"/).flatten.first
    end

    def phone          
      bsjson.scan(/infoWindow\:\{.*phones\:\[\{number\:\"(.*?)\"\}\]/).flatten.first
    end

    def lat          
      bsjson.scan(/viewport\:{center:{lat\:([-]?\d+\.\d+),/).flatten.first ||
        bsjson.scan(/https[:]\/\/.*?\.google\.com\/cbk\?output[=]thumbnail.*?ll=([-]?\d+\.\d+)\,[-]?\d+\.\d+/).flatten.first
    end

    def lon            
      bsjson.scan(/viewport\:{center:{lat\:[-]?\d+\.\d+,lng\:([-]?\d+\.\d+)/).flatten.first ||
        bsjson.scan(/https[:]\/\/.*?\.google\.com\/cbk\?output[=]thumbnail.*?ll=[-]?\d+\.\d+\,([-]?\d+\.\d+)/).flatten.first
    end

    def images
      if original_photo
        if original_photo.scan("logo.").flatten.first != "logo."
          photo = unhex( original_photo )
          # EDIT UP SIZE BY ONE ZERO
          photo = photo.gsub(/\/s(\d\d)\//, "/s\\1"+"0/") unless !photo
          photo = photo.gsub(/\&w\=(\d\d)\&/, "&w=\\1"+"0&") unless !photo
          photo = photo.gsub(/\&h\=(\d\d)\&/, "&h=\\1"+"0&") unless !photo
          photo = photo.gsub(/\&zoom\=0/, "&zoom=3") unless !photo
          [{ url: photo, source: unhex( original_photo ), credit: 'Google' }].to_sa
        end
      end
    end

    def country_code          
      bsjson.scan(/sxcn\:\"(.*?)\"/).flatten.first
    end

    private

    def original_photo          
      bsjson.scan(/photoUrl\:\"(.*?)\"/).flatten.first
    end

    def link_name
      unhex( trim(text) ) unless text.scan(/\A[-.,0-9 ]*\Z/).flatten.first
    end

    def address_lines            
      bsjson.scan(/infoWindow\:\{.*addressLines\:\[(.*?)\]/).flatten.first
    end

    memoize :names, :full_address, :locality, :region, :postal_code, :country, :street_address, 
            :website, :lat, :lon, :images, :country_code, :original_photo, :address_lines
  end
end