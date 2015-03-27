class HtmlToYaml
  attr_accessor :base_path, :html, :data
  def initialize(full_path: nil, end_path: nil, url: nil)
    @base_path = full_path || File.join(Rails.root, 'spec', 'support', 'pages', end_path)
    @html = File.read( "#{base_path}.html" )
    @data = Services::SiteScraper.build(url, html).data.to_super if url
  end

  def write!
    File.open( "#{base_path}.yml", 'w' ) { |f| f.write yaml }
  end

  def yaml
    @yaml ||= data.to_yaml
  end

  def original_data
    @original_data ||= YAML.load_file("#{base_path}.yml").to_super
  end

  def find(name:, original: false)
    datastore = original ? original_data : data
    datastore.find{ |e| e.place && (e.place.name == name || e.place.names.try(:include?, name) ) }
  end

end