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
    "#{pin_on_circle_icon} <span class='gray'>#{marks.count} pins and #{plans.count} plans</span> <span class='gray large-screen-inline'>across #{marks.allcountries.count} countries and _#{} continents</span>".html_safe
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

  private

  def pin_on_circle_icon
    h.content_tag :span, :class => 'fa-stack gray' do
      "<i class='fa fa-circle fa-stack-2x'></i><span class='icon-place fa-stack-1x fa-inverse'></span>".html_safe
    end
  end

  def show_bookmarklet_button
    link_to "#{ render partial: 'bookmarklets/bookmarklet.js.erb', locals: { user: (current_user ? current_user : OpenStruct.new(slug: 'fake-user')), host: request.base_url } }", :class => "a-override u-none" do
      h.content_tag :div, :class => 'no-activity-button blue planit-button enabled' do
        "<i class='fa fa-globe'></i>".html_safe
      end
    end
  end

end