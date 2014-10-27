module ScraperHelper
  def scraper
    Services::SiteScraper.build(@url, html)
  end

  def html
    File.read( file_path('html') )
  end

  def expectations
    File.read( file_path('rb') )
  end

  def file_path(ending)
    File.join('spec', 'support', 'pages', @base_domain, "#{@base_name}.#{ending}")
  end
end