class UserDecorator < Draper::Decorator
  delegate_all
  include Draper::LazyHelpers

  def display_name
    content_tag :a, href: user_path(model) do
      name
    end
  end

  def profile_image
    if image?
      content_tag :a, href: user_path(model) do
        image_tag(model.image)
      end
    else
      ''
    end
  end

  def show_travel_stats_as_caption
    "#{pin_on_circle_icon} <span class='gray'>#{marks.count} pins and #{plans.count} plans</span> <span class='gray large-screen-inline'>across #{marks.all_localities.count} cities & #{marks.all_countries.count} countries</span>".html_safe
  end

  def show_no_plans_alert
    "You don't have any plans or guides saved yet!  Start here:"    
  end

  def show_no_pins_alert
    "You don't have any places saved in the last month!  Do you have the planit 'save' tool?  Drag and drop the icon into your browser's bookmark bar -- and use it to save destination reviews and websites:"
  end

  def show_create_plan_button
    h.content_tag :div, :class => 'no-activity-button blue planit-button enabled' do
      "<i class='fa fa-paper-plane'></i> #{link_to "Create a Plan!", new_plan_path()}".html_safe
    end
  end

  def show_bookmarklet_button_with_text
    "#{show_bookmarklet_button} Planit Bookmarklet".html_safe
  end

  def page_type_title(page_type)
    return image_tag('logo_guides_only.png', alt: 'GUIDES', class: 'logo-title-top largest-screen', style: 'width: 88px') if page_type == 'guides'
    return image_tag('logo_map_only.png', alt: 'MAP', class: 'logo-title-top largest-screen', style: 'width: 55px') if page_type == 'places'
    return image_tag('logo_inbox_only.png', alt: 'INBOX', class: 'logo-title-top largest-screen', style: 'width: 80px') if page_type == 'inbox'
    return image_tag('logo_new_only.png', alt: 'ADD NEW', class: 'logo-title-top largest-screen', style: 'width: 117px') if page_type == 'new'
  end

  # NAVBARS

  def nav_item_map(page_type)
    return nav_item('map', 'my places', 'icon-map4', nil, nil) if page_type == 'places'
    nav_item('map', 'my places', 'icon-map4', user_path(model)+'/places', nil)
  end

  def nav_item_list(page_type)
    return nav_item('guides', 'my guides', 'fa fa-list', nil, nil) if (page_type == 'guides' || page_type == 'plan')
    nav_item('guides', 'my guides', 'fa fa-list', user_path(model)+'/guides', nil)
  end

  def nav_item_new(page_type)
    return nav_item('new', 'add new', 'fa fa-plus-circle', nil, 'disabled') if page_type == 'new'
    nav_item('new', 'add new', 'fa fa-plus-circle', nil, true)
  end

  def nav_item_inbox(page_type)
    return nav_item('inbox', 'my inbox', 'fa fa-inbox', nil, 'disabled') if page_type == 'inbox'
    nav_item('inbox', 'my inbox', 'fa fa-inbox', nil, 'disabled') # user_path(model)+'/inbox' 
  end

  def nav_item_share(page_type)
    return nav_item('share', 'share this', 'fa fa-paper-plane', nil, 'disabled') if (page_type == 'inbox' || page_type == 'howto' || page_type == 'welcome' || page_type == 'static')
    nav_item('share', 'share this', 'fa fa-paper-plane', nil, true)
  end

  # 

  def search_teaser(page_type)
    html = "<div class='search-teaser"
    html += " full-width" unless ( page_type == 'guides' || page_type == 'places')
    html += "'><span id='search-teaser-field'></span><i class='fa fa-search fa-lg'></i></div>"
    html.html_safe
  end

  def filter_or_tag_button(page_type)
    return "<i class='filter-or-number fa fa-sliders fa-lg' id='number_filtered'></i> <i class='fa fa-caret-down'></i>".html_safe if page_type == 'places' 
    return "<i class='tag-or-number fa fa-tag fa-lg' id='number_of_tags'></i> <i class='fa fa-caret-down'></i>".html_safe if page_type == 'guides' 
  end

  def filter_dropdown_menu(page_type)
    html = "<ul class='dropdown-menu dropdown-menu-left filter-dropdown-menu'>"
    if page_type == 'places'
      html += "<li class='filter-dropdown-menu'>"
      html +=   "<div class='apply-filters'>Apply Filters:</div>"
      html +=   "<div class='clear-all-filters'>Clear All Filters<b>×</b></div>"
      html += "</li>"
      html += "<li class='divider nearby-user-location'></li>"
      html += "<li class='filter-dropdown-menu nearby-user-location'>"
      html +=   "<label><input type='checkbox' class='filter-dropdown-menu-nearby' id='nearby' disabled='true'>Nearby<i class='filter-dropdown-menu-icon fa fa-compass'></i></label>"
      html += "</li>"
      html += "<li class='divider'></li>"
      html += "<li class='filter-dropdown-menu'>"
      html +=   "<label><input type='checkbox' class='filter-dropdown-menu-checkbox' id='loved'>Only Most Loved<i class='filter-dropdown-menu-icon fa fa-heart'></i></label>"
      html += "</li>"
      html += "<li class='filter-dropdown-menu'>"
      html +=   "<label><input type='checkbox' class='filter-dropdown-menu-checkbox' id='hide-been'>Hide Already Visited<i class='filter-dropdown-menu-icon fa fa-check-square'></i></label>"
      html += "</li>"
      html += "<li class='divider'></li>"
      html += "<li class='filter-dropdown-menu'>"
      html +=   "<label><input type='checkbox' class='filter-dropdown-menu-checkbox' id='food'>Food & Markets<i class='filter-dropdown-menu-icon icon-local-restaurant'></i></label>"
      html += "</li>"
      html += "<li class='filter-dropdown-menu'>"
      html +=   "<label><input type='checkbox' class='filter-dropdown-menu-checkbox' id='drink'>Drink & Nightlife<i class='filter-dropdown-menu-icon icon-local-bar'></i></label>"
      html += "</li>"
      html += "<li class='filter-dropdown-menu'>"
      html +=   "<label><input type='checkbox' class='filter-dropdown-menu-checkbox' id='seedo'>See & Do<i class='filter-dropdown-menu-icon icon-directions-walk'></i></label>"
      html += "</li>"
      html += "<li class='filter-dropdown-menu'>"
      html +=   "<label><input type='checkbox' class='filter-dropdown-menu-checkbox' id='stay'>Stay<i class='filter-dropdown-menu-icon icon-home'></i></label>"
      html += "</li>"
      html += "<li class='filter-dropdown-menu'>"
      html +=   "<label><input type='checkbox' class='filter-dropdown-menu-checkbox' id='relax'>Relax<i class='filter-dropdown-menu-icon icon-drink'></i></label>"
      html += "</li>"
      html += "<li class='filter-dropdown-menu'>"
      html +=   "<label><input type='checkbox' class='filter-dropdown-menu-checkbox' id='other'>Other<i class='filter-dropdown-menu-icon fa fa-question'></i></label>"
      html += "</li>"
      html += "<li class='divider'></li>"
      html += "<li class='filter-dropdown-menu'>"
      html +=   "<label><input type='checkbox' class='filter-dropdown-menu-checkbox' id='open'>Open<i class='filter-dropdown-menu-icon fa fa-clock-o'></i></label>"
      html += "</li>"
      html += "<li class='filter-dropdown-menu'>"
      html +=   "<label><input type='checkbox' class='filter-dropdown-menu-checkbox' id='wifi'>Wifi<i class='filter-dropdown-menu-icon fa fa-wifi'></i></label>"
      html += "</li>"
    elsif page_type == 'guides'
      html += "<li class='tag-dropdown-menu'>"
      html +=   "<div class='apply-filters'>Narrow By Tag:</div>"
      html +=   "<div class='clear-all-filters'>See All Guides <b>×</b></div>"
      html += "</li>"
      html += "<li class='divider'></li>"
      marks.all_tags.each do |tag|
        html += "<li class='tag-dropdown-menu'>"
        html +=   "<label><input type='checkbox' class='tag-dropdown-menu-checkbox' id='#{tag}'>#{tag}</label>"
        html += "</li>"
      end
    end
    html += "</ul>"
    html.html_safe
  end

  def user_dropdown_menu
    html = "<ul class='dropdown-menu dropdown-menu-right user-dropdown-menu'>"
    if current_user
      html += "<li class='user-dropdown-menu'>"
      html +=   "<a href='" + edit_user_registration_path + "'>Update Account<i class='user-dropdown-menu-icon fa fa-user fa-fw'></i></a>"
      html += "</li>"
      html += "<li class='user-dropdown-menu mobile'>"
      html +=   "<a href='" + legal_support_path + "'>Legal & Support<i class='user-dropdown-menu-icon fa fa-question fa-fw'></i></a>"
      html += "</li>"
      html += "<li class='divider'></li>"
      html += "<li class='user-dropdown-menu'>"
      html +=   "<a href='" + destroy_user_session_path + "' data-method='delete'>Log Out<i class='user-dropdown-menu-icon fa fa-times fa-fw'></i></a>"
      html += "</li>"
    else
      html += "<li class='user-dropdown-menu'>"
      html +=   "<a href='" + new_user_session_path + "'>Log In<i class='user-dropdown-menu-icon fa fa-user fa-fw'></i></a>"
      html += "</li>"
      html += "<li class='user-dropdown-menu'>"
      html +=   "<a href='" + new_user_registration_path + "'>Sign Up<i class='user-dropdown-menu-icon fa fa-user fa-fw'></i></a>"
      html += "</li>"
    end
    html += "</ul>"
    html.html_safe
  end

  def inject_modals(array)
    injection = ''
    array.each do |type|
      html = ''
      if type == 'share'
        html += "            <label for='recipient-name' class='control-label'>Share with:</label>"
        html += "            <input type='text' class='form-control share-with' id='recipient' placeholder='Email Address'>"
        html += "          </div>"
        html += "          <div class='form-group'>"
        html += "            <label for='message-text' class='control-label'>Note:</label>"
        html += "            <textarea class='form-control' id='message-text'></textarea>"
      elsif type == 'new'
        html += "            <input type='text' class='form-control new-pin-nearby input-with-clear' id='nearby' placeholder='Nearby Location'><span class='clear-input-button' id='clear-new-pin-nearby'><i class='fa fa-times-circle'></i></span>"
        html += "          </div>"
        html += "          <div class='form-group'>"
        html += "            <input type='text' class='form-control new-pin-query' id='query' placeholder='Place Name'>"
      end
      title = 'Share the Love' if type == 'share'
      title = 'Add a New Pin' if type == 'new'
      submit = 'Share' if type == 'share'
      submit = 'Add' if type == 'new'
      injection += modal(type, title, submit, html)
    end
    injection.html_safe
  end

  # PRIVATE

  private

  def pin_on_circle_icon
    h.content_tag :span, :class => 'fa-stack gray' do
      "<i class='fa fa-circle fa-stack-2x'></i><span class='icon-place fa-stack-1x fa-inverse'></span>".html_safe
    end
  end

  def show_bookmarklet_button
    link_to "#{ render partial: 'bookmarklets/bookmarklet.js.erb', locals: { user: (current_user ? current_user : OpenStruct.new(slug: 'fake-user')), host: request.base_url } }", :class => "a-override u-none" do
      h.content_tag :div, class: 'no-activity-button blue planit-button enabled' do
        "<i class='fa fa-globe'></i><div class='hidden_button_name'>+Planit</div>".html_safe
      end
    end
  end

  def nav_item(type, hint, icon, link_to, modal)
    selected = if (!link_to.present? && !modal.present?) then true else false end
    disabled = if (modal == 'disabled') then true else false end
    html = ''
    html += "<a href='#{link_to}'" if link_to
    html += "<a href='#'" if selected || disabled
    html += "<a href='#planit-modal-#{type}' data-toggle='modal' data-target='#planit-modal-#{type}' data-backdrop='static' data-keyboard='false'" if ( modal && !disabled )
    html += " class='nav-item-link"
    html += " selected" if selected
    html += " disabled" if disabled
    html += "'"
    html += "><div class='nav-item nav-item-#{type}"
    html += " selected" if selected
    html += " disabled" if disabled
    html += "'>"
    html += "<i class='nav-item-icon #{icon}'></i><div class='nav-item-hint'><span>#{hint.upcase}</span></div></div>"
    html += "</a>"
    html.html_safe
  end

  def modal(type, title, submit, form_content)
    html = ''
    html += "<div class='modal fade planit-modal' id='planit-modal-#{type}' tabindex='-1' role='dialog' aria-labelledby='exampleModalLabel' aria-hidden='true'>"
    html += "  <div class='modal-dialog'>"
    html += "    <div class='modal-content'>"
    html += "      <div class='modal-header'>"
    html += "        <button type='button' class='close' data-dismiss='modal' aria-label='Close'><span aria-hidden='true'>&times;</span></button>"
    html += "        <h4 class='modal-title' id='exampleModalLabel'>#{title}</h4>"
    html += "      </div>"
    html += "      <div class='modal-body'>"
    html += "        <form id='planit-modal-form-#{type}'>"
    html += "          <div class='form-group'>"
    html += form_content
    html += "          </div>"
    html += "        </form>"
    html += "      </div>"
    html += "      <div class='modal-footer'>"
    html += "        <a href='https://developer.foursquare.com/'><img class='poweredbyfoursquare' src='https://ss0.4sqi.net/img/devsite/img_poweredby-181a0c7c0fe5f3576d97bcf29ce69d24.png' alt='foursquare'></a>" if type == 'new'
    html += "        <button type='button' class='btn btn-default' data-dismiss='modal'>Cancel</button>"
    html += "        <button type='button' class='btn btn-primary' id='planit-modal-submit-#{type}'>#{submit}</button>"
    html += "      </div>"
    html += "    </div>"
    html += "  </div>"
    html += "</div>"
    html.html_safe
  end

end