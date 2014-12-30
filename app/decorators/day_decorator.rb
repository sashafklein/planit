class DayDecorator < Draper::Decorator
  delegate_all
  include Draper::LazyHelpers

  def show_locales_in_day
    locale_list = get_locale_list(items)
    html = ''
    if locale_list.present?
      locale_list.each do |l|
        html += "<span class='day-info locale'>#{l}</span> "
      end
    end
    html.html_safe
  end

  def show_distances_in_day
    if day_distance = Distance.items_dist(items_including_prior_days_lodging)
      if day_distance > 0 && day_distance < 10
        content_tag :span, "#{day_distance} miles btw points", :class => 'day-info distance'
      elsif day_distance >= 10
        content_tag :span, "#{day_distance.round(0)} miles btw points", :class => 'day-info distance'
      end
    end
  end

end