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
  end

  def name_attempts
    dup_names = scraper.name_attempts.dup
  end

  def expect_equal(array1, array2)
    array1.each_with_index do |hash, index|
      expect( array1[index] ).to hash_eq( array2[index], {ignore_nils: true} )
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
end