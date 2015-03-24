class ItemDecorator < Draper::Decorator
  delegate_all
  delegate :location_description, :created_or_updated?, to: :place_decorator
  include Draper::LazyHelpers

  def place_decorator
    place.decorate
  end

end
