module ApplicationHelper

  def title(title)
    content_for(:title) { title.gsub("'", "’") }
  end

  def page_title(page_title)
    content_for(:page_title) { page_title }
  end

  def set_page_type(type)
    content_for(:page_type) { type }
  end

  def set_body_style(style)
    content_for(:body_style) { style }
  end
  
  def render_header(type='false')
    render 'application/header', { page_type: type }
  end

  def render_footer(type='false')
    render 'application/footer', { page_type: type }
  end

  def include_templates(*templates)
    @directive_templates ||= []
    templates.each{ |t| @directive_templates << t }
  end

  def yield_with_blank(name, &block)
    content_for(name) == 'false' ? '' : content_for(name)
  end

  def show_filter?(page_type)
    [ 'places' ].include?(page_type)
  end

  def show_search?(page_type)
    [ 'places', 'guides', 'plan' ].include?(page_type)
  end

  def rich_content?(page_type)
    [ 'places', 'place', 'guides', 'plan' ].include?(page_type)
  end

  def show_back?(page_type)
    [ 'new' ].include?(page_type)
  end

  def fullscreen?(page_type)
    [ 'places', 'beta', 'home' ].include?(page_type)
  end

  # DATE-BASED LISTS

  def days_since_string(date)
    "#{(date).strftime('%d %b, %Y')} #{days_ago((Date.today - date.to_date).to_i)}"
  end

  def current_year(year=nil)
    if year
      year == (Date.today).strftime('%Y')
    else
      return (Date.today).strftime('%Y')
    end
  end

  def current_user_id
    current_user ? current_user.id : nil
  end

  def current_user_is_active
    if current_user
      if current_user.admin? || current_user.member?
        return true
      end
    end
  end

  def current_user_owns(record=nil)
    current_user_is_active && ( current_user.owns?(record) || current_user.is?(record) )
  end

  def link_to_email_help(subject: 'Ran into a bug', content: '', link_text: 'let us know', opts: { class: 'linky'})
    (mail_to 'hello@plan.it', link_text, { subject: subject, body: content}.merge(opts)).to_s.gsub("&amp;", '&').html_safe
  end

  def render_javascript?
    !Rails.env.test? || ENV['RENDER_JS']
  end

  private

  # DATE-BASED LISTS

  def days_ago(num)
    if num > 1 
      "(#{num} days ago)"
    elsif num == 1
      "(1 day ago)"
    end
  end

end
