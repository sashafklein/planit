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
      expect( deep_sort_hash(array1[index]) ).to eq( deep_sort_hash(array2[index]) )
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

  private

  def deep_sort_hash(object)
    return object unless object.is_a?(Hash)
    hash = ActiveSupport::OrderedHash.new
    object.each { |k, v| hash[k] = deep_sort_hash(v) }
    sorted = hash.sort { |a, b| a[0].to_s <=> b[0].to_s }
    hash.class[sorted]
  end

end