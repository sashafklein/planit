class UserDecorator < Draper::Decorator
  delegate_all
  include Draper::LazyHelpers

  def travel_stats_string
    "#{pin_on_circle_icon} <span class='gray'>#{marks.count} pins and #{plans.count} plans</span> <span class='gray large-screen-inline'>across #{marks.all_localities.count} cities & #{marks.all_countries.count} countries</span>".html_safe
  end

  def bookmarklet_link_to
    "#{ render partial: 'bookmarklets/bookmarklet.js.erb', locals: { user: (current_user ? current_user : OpenStruct.new(slug: 'fake-user')), host: request.base_url } }"
  end

  def pin_on_circle_icon
    h.content_tag :span, :class => 'fa-stack gray' do
      "<i class='fa fa-circle fa-stack-2x'></i><span class='icon-place fa-stack-1x fa-inverse'></span>".html_safe
    end
  end

  # MODALS LOGIC

  def new_place_modal
    title = 'Add a New Pin'
    submit = 'Add'
    html = """
                <label for='new-pin-nearby' class='control-label'>Near:</label>
                <div class='clear-input-box'><input type='text' class='form-control input-with-clear new-pin-nearby' id='nearby' placeholder='Location'><span class='clear-input-button'><i class='fa fa-times-circle'></i></span></div>
              </div>
              <div class='form-group'>
                <label for='new-pin-query' class='control-label'>Name:</label>
                <div class='clear-input-box'><input type='text' class='form-control input-with-clear new-pin-query' id='query' placeholder='Place or Destination'><span class='clear-input-button'><i class='fa fa-times-circle'></i></span></div>
    """
    modal('new', title, submit, html).html_safe
  end

  def share_modal
    title = 'Share the Love'
    submit = 'Share'
    html = """
                <label for='recipient-name' class='control-label'>Share with:</label>
                <div class='clear-input-box'><input type='text' class='form-control input-with-clear share-with' id='recipient' placeholder='Email Address'><span class='clear-input-button'><i class='fa fa-times-circle'></i></span></div>
              </div>
              <div class='form-group'>
                <label for='message-text' class='control-label'>Personal Note:</label>
                <textarea class='form-control' id='message-text'></textarea>
    """
    modal('share', title, submit, html).html_safe
  end

  def modal(type, title, submit, form_content)
    foursquare_credit = "<a href='https://developer.foursquare.com/'><img class='poweredbyfoursquare' src='https://ss0.4sqi.net/img/devsite/img_poweredby-181a0c7c0fe5f3576d97bcf29ce69d24.png' alt='foursquare'></a>" if type == 'new'
    html = """
      <div class='modal fade planit-modal' id='planit-modal-#{type}' tabindex='-1' role='dialog' aria-hidden='true'>
        <div class='modal-dialog'>
          <div class='modal-content'>
            <div class='modal-header'>
              <button type='button' class='close' data-dismiss='modal' aria-label='Close'><span aria-hidden='true'>&times;</span></button>
              <h4 class='modal-title'>#{title}</h4>
            </div>
            <div class='modal-body'>
              <form id='planit-modal-form-#{type}'>
                <div class='form-group'>
                #{ form_content }
                </div>
              </form>
            </div>
            <div class='modal-footer'> 
              #{foursquare_credit}
              <button type='button' class='btn btn-default' data-dismiss='modal'>Cancel</button>
              <button type='button' class='btn btn-primary' id='planit-modal-submit-#{type}'>#{submit}</button>
            </div>
          </div>
        </div>
      </div>
    """
    html.html_safe  
  end

  # NAVBARS LOGIC

  def nav_item_map(page_type)
    return nav_item('map', 'my places', 'icon-map4', nil, nil) if page_type == 'places'
    nav_item('map', 'my places', 'icon-map4', user_path(model)+'/places', nil)
  end

  def nav_item_list(page_type)
    return nav_item('guides', 'my guides', 'fa fa-book', nil, nil) if (page_type == 'guides')
    nav_item('guides', 'my guides', 'fa fa-book', user_path(model)+'/guides', nil)
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
    html += "'><div class='nav-item nav-item-#{type}"
    html += " selected" if selected
    html += " disabled" if disabled
    html += "'><i class='nav-item-icon #{icon}'></i><div class='nav-item-hint'><span>#{hint.upcase}</span></div></div></a>"
    html.html_safe
  end
end