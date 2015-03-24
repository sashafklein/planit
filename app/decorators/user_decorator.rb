class UserDecorator < Draper::Decorator
  delegate_all
  include Draper::LazyHelpers

  def travel_stats_string
    "#{pin_on_circle_icon} <span class='gray'>#{marks.count} pins and #{plans.count} plans</span> <span class='gray large-screen inline'>across #{marks.all_localities.count} cities & #{marks.all_countries.count} countries</span>".html_safe
  end

  def bookmarklet_link_to
    "#{ render partial: 'bookmarklets/bookmarklet.js.erb', locals: { user: (current_user ? current_user : OpenStruct.new(slug: 'fake-user')), host: request.base_url } }"
  end

  def pin_on_circle_icon
    h.content_tag :span, :class => 'fa-stack gray' do
      "<i class='fa fa-circle fa-stack-2x'></i><span class='icon-place fa-stack-1x fa-inverse'></span>".html_safe
    end
  end

  # NAVBARS LOGIC

  def nav_item_map(page_type)
    return nav_item(type: 'map', hint: 'my places', icon: 'icon-map4') if page_type == 'places'
    nav_item(type: 'map', hint: 'my places', icon: 'icon-map4', link_to: user_path(model)+'/places')
  end

  def nav_item_guides(page_type)
    return nav_item(type: 'guides', hint: 'my guides', icon: 'fa fa-book') if page_type == 'guides'
    nav_item(type: 'guides', hint: 'my guides', icon: 'fa fa-book', link_to: user_path(model)+"/guides#?y=in_"+current_year() )
  end

  def nav_item_new(page_type)
    return nav_item(type: 'new', hint: 'add new', icon: 'fa fa-plus-circle') if page_type == 'new'
    nav_item(type: 'new', hint: 'add new', icon: 'fa fa-plus-circle', modal: true)
  end

  def nav_item_inbox(page_type, current_user)
    return nav_item(type: 'inbox', hint: 'my inbox', icon: 'fa fa-inbox', messages: current_user.messages) if page_type == 'inbox' && current_user.messages > 0
    return nav_item(type: 'inbox', hint: 'my inbox', icon: 'fa fa-inbox', link_to: user_path(current_user)+'/inbox', messages: current_user.messages) if current_user.messages > 0
    nav_item(type: 'inbox', hint: 'my inbox', icon: 'fa fa-inbox', disabled: true)
  end

  def nav_item_share(page_type, user=nil)
    return nav_item(type: 'share', hint: 'share this', icon: 'fa fa-paper-plane', disabled: true) if !rich_content?(page_type) || !shareable_content?(page_type, user)
    nav_item(type: 'share', hint: 'share this', icon: 'fa fa-paper-plane', modal: true)
  end

  def nav_item(type:, hint:, icon:, link_to: nil, modal: nil, disabled: nil, messages: nil)
    selected = (!link_to.present? && !modal.present?)
    message_count = "<span class='inbox-count #{'chill' if !link_to}'>#{messages}</span>" if messages
    html = ''
    html += "<div" if selected || disabled
    html += "<a href='#{link_to}'" if link_to
    html += "<a href='#planit-modal-#{type}' data-toggle='modal' data-target='#planit-modal-#{type}' data-backdrop='static' data-keyboard='false'" if ( modal && !disabled )
    html += " class='nav-item-link"
    html += " selected" if selected
    html += " disabled" if disabled
    html += "'><div class='nav-item nav-item-#{type}"
    html += " selected" if selected
    html += " disabled" if disabled
    html += "'><i class='nav-item-icon #{icon}'>#{message_count}</i><div class='nav-item-hint'><span>#{hint.upcase}</span></div></div>"
    html += "</a>" if link_to || modal
    html += "</div>" if selected || disabled
    html.html_safe
  end

  # PRIVATE

  def shareable_content?(page_type, user)
    return true if user && page_type == 'places' && user.marks.count > 0
    return true if user && page_type == 'guides' && user.plans.count > 0    
  end
end