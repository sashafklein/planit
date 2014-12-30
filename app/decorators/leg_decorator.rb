class LegDecorator < Draper::Decorator
  delegate_all
  include Draper::LazyHelpers

  def show_leg_name
    if name.present?
      "<div class='band gray spaced'><div class='container'><strong>#{name}</strong></div></div>".html_safe
    end
  end

end
