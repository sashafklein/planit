module ScraperHelper
  def scraper
    Services::SiteScraper.build(@url, html)
  end

  def html
    File.read( file_path('html') )
  end

  def expectations
    YAML.load_file( file_path('yml') ).map(&:symbolize_keys)
  end

  def file_path(ending)
    File.join('spec', 'support', 'pages', @base_domain, "#{@base_name}.#{ending}")
  end
  
  def get_domain(url)
    full_domain = URI(url).host.match(/[^\.]+\.\w+$/).to_s
    no_extension = full_domain.split(".")[0]
  end

end