class HeaderDecorator < Draper::Decorator
  delegate_all
  include Draper::LazyHelpers

end