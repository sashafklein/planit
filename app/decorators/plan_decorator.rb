class PlanDecorator < Draper::Decorator
  delegate_all
  include Draper::LazyHelpers

  # USER DASHBOARD

  def created_or_updated_at_link
    "#{created_or_updated?} #{link_to( name, plan_path(model), class: 'strong' )}".html_safe  
  end

  def created_or_updated?
    created_at == updated_at ? "Created" : "Updated"
  end

  # PLAN_SHOW

  def show_plan_dates
    if updated_at.present?
      if created_at.present? && updated_at == created_at 
        "<div class='plan-more-info-wrap'><span class='plan-more-info'>#{updated_at.strftime('%b %Y')}</span></div>".html_safe
      elsif !created_at.present?
        "<div class='plan-more-info-wrap'><span class='plan-more-info'>#{updated_at.strftime('%b %Y')}</span></div>".html_safe
      else
        "<div class='plan-more-info-wrap'><span class='plan-more-info'>#{updated_at.strftime('%b %Y')} <i>| original #{created_at.strftime('%b %Y')}</i></span></div>"
      end
    elsif created_at.present? && !updated_at.present?
      "<div class='plan-more-info-wrap'><span class='plan-more-info'><i>#{created_at.strftime('%b %Y')}</i></span></div>".html_safe
    end
  end

  def show_locales_in_bucket
    if bucket.any?
      locale_list = get_locale_list(bucket.marks)
      html = ''
      if locale_list.present?
        locale_list.each do |l|
          html += "<span class='day-info locale'>#{l}</span> "
        end
      end
      html.html_safe
    end
  end

end