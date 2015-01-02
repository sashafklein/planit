class MarkDecorator < Draper::Decorator
  delegate_all
  delegate :location_description, :created_or_updated?, to: :place_decorator
  include Draper::LazyHelpers

  def place_decorator
    place.decorate
  end

  # DASHBOARD

  def created_or_updated_at_link
    "#{created_or_updated?} #{link_to( name, place_path(model.place), class: 'strong' )} #{location_description}".html_safe  
  end

  def created_or_updated?
    created_at == updated_at ? "Added" : "Updated"
  end

  # TAB_SHOW

  def show_image_or_noimage
    if image
      link_to image_tag(image.url), place_path(place), :class => 'mark-tab-img'
    else
      link_to show_noimage_icon.html_safe, place_path(place)
    end
  end

  private

  def show_noimage_icon
    content_tag :div, "<i class='add-photo-camera fa fa-camera-retro fa-2x'></i>".html_safe, :class => 'mark-tab-img add-photo'
  end

end