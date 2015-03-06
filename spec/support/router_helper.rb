class RouterHelper  
  def self.get_routes_by_controller(exceptions=nil)
    basic_get_routes(exceptions).group_by(&:ctrl)
  end

  def self.basic_get_routes(exceptions=nil)
    routes = Rails.application.routes.routes.map{ |r| new(r, exceptions) }
      .select(&:valid?)
      .select{ |r| r.is?('get') }
  end

  attr_accessor :route, :exceptions
  def initialize(route, exceptions=nil)
    @route, @exceptions = route, exceptions
  end

  def valid?
    exclude = %w(assets devise) + Array(exceptions).flatten.compact
    !exclude.any? { |path| full_path.include?( path )} &&
      !exclude.any?{ |ctrl| naked_ctrl.include?( ctrl ) }
  end

  def is?(type)
    types.include?(type)
  end

  def sub_path
    base = full_path.split("/").last
    return :index if base.nil?
    return :show if base.include?(":")
    base
  end

  def full_path
    route.path.spec.to_s.gsub("(.:format)", '')
  end

  def ctrl
    base = naked_ctrl.split('/').map{ |s| s.camelize }.join('::')
    "#{base}Controller".constantize
  end

  def required_objects
    full_path.scan(required_objects_regex).inject({}) do |hash, path_and_id_type|
      hash[path_and_id_type.last] = path_and_id_type.first.gsub("/", '').singularize ; hash
    end
  end

  private


  def required_objects_regex
    %r{(/[^/]+)/:([^/]+)}
  end

  def naked_ctrl
    route.defaults[:controller]
  end

  def types
    %w( get put post delete ).select{ |method| route.constraints[:request_method].to_s.include?(method.upcase) }
  end
end