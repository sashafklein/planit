class UrlObjectParser
  
  attr_accessor :path
  def initialize(path)
    @path = path
  end

  def objects
    models_in_path.inject({}) do |hash, model|
      split_path = path.split(/(?:^|\/)#{ model }(?:\/|\?|\&|$)/)
      query_string_split = path.split(/\?#{ model.singularize }=/)
      id = split_path.count == 1 ? nil : split_path.last.try(:split, /(?:\/|\?|\&|$)/).try(:first)
      id ||= query_string_split.count == 1 ? nil : query_string_split.last.try(:split, /(?:\&|$)/).try(:first)
      hash[model.singularize.capitalize] = id
      hash
    end.to_sh.reject_val(&:nil?)
  end

  private

  def models_in_path
    models.select{ |m| path.scan(/(?:^|\/)#{ m }/).any? } + models.select{ |m| path.scan(/\?#{ m.singularize }\=/).any? }
  end

  def models
    model_files.map{ |f| f.gsub('.rb', '') }.map(&:pluralize)
  end

  def model_files
    Dir.open("#{Rails.root}/app/models/").entries
      .reject{ |e| e.first == '.' }
      .reject{ |e| e.last(3) != '.rb' }
      .reject{ |e| non_models.include?( e.gsub('.rb', '')) }
  end

  def non_models
    %w( base_model category_set icon tag tagging )
  end

end
