module ApplicationHelper

  def title(title)
    content_for(:title) { title.gsub("'", "’") }
  end

  def page_title(page_title)
    content_for(:page_title) { page_title }
  end

  def header(options={})
    content_for(:header) { options ? render_header(options) : 'false' }
  end

  def page_type(name)
    content_for(:page_type) { name }
    header(page_type: name); footer(page_type: name)
  end

  def footer(options={})
    content_for(:footer) { options ? render_footer(options) : 'false' }
  end

  def render_header(options={})
    render 'application/header', { background: 'white', color: 'black', start: '', page_type: '' }.merge(options)
  end

  def render_footer(options={})
    render 'application/footer', { page_type: '' }.merge(options)
  end

  def yield_with_blank(name, &block)
    content_for(name) == 'false' ? '' : content_for(name)
  end

  def show_filter?(page_type)
    [ 'places', 'guides' ].include?(page_type)
  end

  def show_search?(page_type)
    [ 'places', 'guides', 'plans', 'inbox' ].include?(page_type)
  end

  def rich_content?(page_type)
    [ 'places', 'place', 'guides', 'plans' ].include?(page_type)
  end

  def show_back?(page_type)
    [ 'new' ].include?(page_type)
  end

  def fullscreen?(page_type)
    [ 'places' ].include?(page_type)
  end

  # DATE-BASED LISTS

  def days_since_string(date)
    "#{(date).strftime('%d %b, %Y')} #{days_ago((Date.today - date.to_date).to_i)}"
  end

  def current_year(year)
    year == (Date.today).strftime('%Y')
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

  def current_user_owns_record
    if @user && current_user_is_active
      @user == current_user
    end
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
