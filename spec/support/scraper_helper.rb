module ScraperHelper
  def scraper
    Services::SiteScraper.build(@url, html)
  end

  def html
    if file_name == 'general'
      Nokogiri(open(@url)).inner_html
    else
      File.read( file_path('html') )
    end
  rescue
    ''
  end

  # def set_yaml
  #   # FIX
  #   data.to_yaml # to file, gsub \n for line break, gsub \" for quote "
  # end

  def data
    dup_data = scraper.data.dup
    dup_data.map do |hash|
      hash.recursive_delete_if{ |k, v| v.nil? || (v.is_a?(String) && v.empty?) }
    end
  # rescue => e
  #   binding.pry
  end

  def name_attempts
    dup_names = scraper.name_attempts.dup
  end

  def expect_equal(array1, array2, also_ignore=[])
    array1.each_with_index do |hash, index|
      hash1, hash2 = *[array1[index], array2[index]].map(&:dup).map(&:to_sh)
      float_attrs = [:lat, :lon]
      sorta_eq_attrs = [:sublocality, :locality, :region, :subregion, :country]
      dont_care_attrs = [:images, :extra, :ratings, :hours, :phones, :price_note, :hours_note, :phones].concat(also_ignore).uniq

      p1, p2 = hash1.delete(:place), hash2.delete(:place)

      dont_care_attrs.each do |a| 
        p1.delete(a); p2.delete(a)
      end

      float_attrs.each do |a| 
        next unless p1[a] && p2[a]
        expect( p1[a].to_f ).to float_eq p2[a].to_f
        p1.delete(a); p2.delete(a)
      end

      sorta_eq_attrs.each do |a| 
        next unless p1[a] && p2[a]
        as = [p1[a], p2[a]].map(&:to_s)
        
        expect( as.first ).to sorta_eq as.last
        p1.delete(a); p2.delete(a)
      end

      p1.reject{ |k, v| v.blank? }.each_pair do |k, v|
        expect( p1[k].is_a?(String) ? p1[k].without_common_symbols : p1[k] ).to eq p2[k].is_a?(String) ? p2[k].without_common_symbols : p2[k]
      end

      expect( hash1 ).to hash_eq( hash2, { ignore_nils: true, ignore_keys: [:user_data] } )
    end
  end

  def expectations
    YAML.load_file( file_path('yml') ).map(&:recursive_symbolize_keys!)
  end

  def file_path(ending)
    File.join('spec', 'support', 'pages', "#{file_name}.#{ending}")
  end

  def file_name
    @base_domain ? "#{@base_domain}/#{@base_name}" : 'general'
  end
  
  def get_domain(url)
    full_domain = URI(url).host.match(/[^\.]+\.\w+$/).to_s
    no_extension = full_domain.split(".")[0]
  end

  def yml_data(base, url_or_folder, search_term=nil)
    @base_name = base
    @base_domain = url_or_folder.include?('.') ? get_domain(url_or_folder) : url_or_folder
    search_term ? expectations.find{ |p| p[:place][:name] == search_term || Array(p[:place][:names]).include?(search_term) } : expectations.first
  end

  def read(folder, name)
    File.read File.join( Rails.root, 'spec', 'support', 'pages', folder, name )
  end

  def completed_data(filename:, scrape_url:, name: nil)
    @yml = yml_data(filename, scrape_url, name)
    Completers::Completer.new(@yml, @user, @yml[:scraper_url]).complete!
  end

  # Creates YML file from HTML file
  def scrape!(file, url)
    full_path = File.join( Rails.root, 'spec', 'support', 'pages', "#{file}")
    s = Services::SiteScraper.build(url, File.read("#{full_path}.html") )
    File.open("#{full_path}.yml", 'w') { |file| file.write(s.data.to_yaml) }
  end

  def run_test(name, url, also_ignore=[], run=false)
    return true unless run
    @base_name, @url = name, url
    @base_domain = get_domain @url
    binding.pry
    expect_equal data, expectations, also_ignore
  end

  def self.manifest
    YAML.load_file(File.join(Rails.root, 'spec', 'support', 'pages', 'manifest.yml')).to_super
  end

end