class PlaceDecorator < Draper::Decorator
  delegate_all
  include Draper::LazyHelpers

  # DASHBOARD

  def location_description
    if sublocality.present?
      ["in #{sublocality}", location_locality_parenthetical].compact.join(" ")
    elsif locality.present?
      ["in #{locality}", location_country_of_locality_parenthetical].compact.join(" ")
    elsif region.present?
      ["in #{region}", location_country_of_region_parenthetical].compact.join(" ")
    elsif country.present?
      country
    end
  end

  def created_or_updated?
    created_at == updated_at ? "Added" : "Updated"
  end

  # PLACE_SHOW

  def show_categories
    if categories && categories.length > 0
      content_tag :div, categories.join(", ").titleize, :class => 'place-page-category'
    else
      content_tag :div, :class => 'place-page-category' do
        content_tag :span, "<i class='fa fa-pencil place-show-icon'></i>Edit Destination Type".html_safe, :class => 'gray'
      end
    end
  end

  def show_alt_names_in_parens
    if alt_names.any?
      content_tag :div, "(#{names.drop(1).join('), (')})", :class => 'address-info-line'
    end
  end

  def show_address_linked_to_directions
    link_to "https://maps.google.com?daddr=#{lat},#{lon}", :class => 'a-override a-black u-none h-black s-neon' do
      show_street_or_full_address + show_locality_zip_and_region + show_country
    end
  end

  def show_street_or_full_address
    if street_address.present?
      content_tag :div, :class => 'address-info-line' do
        content_tag :span, street_address, :class => 'to-highlight'
      end
    elsif full_address.present?
      content_tag :div, :class => 'address-info-line' do
        content_tag :span, full_address, :class => 'to-highlight'
      end
    end
  end

  def show_locality_zip_and_region
    if [locality, region, postal_code].reject(&:blank?).present?
      content_tag :div, :class => 'address-info-line' do
        content_tag :span, [locality, region, postal_code].reject(&:blank?).join(', '), :class => 'to-highlight'
      end
    end
  end

  def show_country
    if country
      content_tag :div, :class => 'address-info-line' do
        content_tag :span, country, :class => 'to-highlight'
      end
    end
  end

  def show_website
    if website.present?
      content_tag :div, class: 'address-info-line truncate' do
      h.link_to website, website, :title => 'website'
      end
    end
  end

  def show_phones
    if phones.any?
      html = ''
      phones.map do |type, number|
        html += "<div class='address-info-line'>"
        html += "<i class='fa fa-phone place-show-icon'></i>"
        html += number
        html += "</div>"
      end
      return html.html_safe
    end
  end

  def show_photos_or_noimage
    if image
      show_place_photo_gallery
    else
      "<div class='photos-gallery'><div class='add-photo'><i class='fa fa-camera-retro'></i>ADD PHOTO</div></div>".html_safe
    end
  end

  def show_hours
    html = ''
    if hours.any?
      %w( sun mon tue wed thu fri sat ).each do |day|
        if day == today = Date.today.strftime('%a').downcase
          html += "<div class='show-hours-line today'><i class='show-hours-day'>#{day.titleize}:</i> #{hours[day].scan(/start[_]time\=\>\"([^"]*)\"/).flatten.first} to #{hours[day].scan(/end[_]time\=\>\"([^"]*)\"/).flatten.first}</div>"
        else
          html += "<div class='show-hours-line'><i class='show-hours-day'>#{day.titleize}:</i> #{hours[day].scan(/start[_]time\=\>\"([^"]*)\"/).flatten.first} to #{hours[day].scan(/end[_]time\=\>\"([^"]*)\"/).flatten.first}</div>"
        end
      end
    end
    html.html_safe
  end

  def show_open_today
    
    if open_until.present?
      content_tag :div, "<i class='fa fa-clock-o'></i> Open now (until #{open_until})".html_safe, :class => 'hours-availability-booking-content open-now'
    elsif open_again_at.present? 
      content_tag :div, "<i class='fa fa-clock-o'></i> Closed now (opens today at #{open_again_at})".html_safe, :class => 'hours-availability-booking-content closed-now'
    end
  end

  def show_reservations_maker
    # if reservations.any?
    #   content_tag :div, :class => 'more-info-line' do
    #     "<i class='fa fa-calendar place-show-icon'></i>Takes Reservations"
    #   end
    # end
  end

  def show_reservations
    # if reservations.any?
    #   content_tag :div, :class => 'more-info-line' do
    #     "<i class='fa fa-calendar place-show-icon'></i>Takes Reservations"
    #   end
    # end
  end

  def show_price_info
    if price_tier.present? || price_note.present?
      content_tag :div, :class => 'more-info-line' do
        if !price_note.present?
          "<i class='fa fa-money place-show-icon'></i> #{show_price_tier}".html_safe
        elsif !price_tier.present?
          "<i class='fa fa-money place-show-icon'></i> #{show_price_note}".html_safe
        else
          "<i class='fa fa-money place-show-icon'></i> #{show_price_tier} | #{show_price_note}".html_safe
        end
      end
    end
  end

  def show_view_menu
    # if menu.present?
    #   content_tag :div, :class => 'more-info-line' do
    #     "<i class='fa fa-cutlery place-show-icon'></i> #{link_to menu.url, 'View Menu'}".html_safe
    #   end
    # end
  end

  def show_has_wifi
    # if wifi == true
    #   content_tag :div, :class => 'more-info-line' do
    #     "<i class='fa fa-wifi place-show-icon'></i> Has WiFi".html_safe
    #   end
    # end
  end

  private

  # DASHBOARD

  def location_locality_parenthetical
    if locality.present? && locality != sublocality && not_in_usa?
      "(#{locality}, #{country})"
    end
  end

  def location_country_of_locality_parenthetical
    if not_in_usa?
      "(#{country})"
    elsif region.present? && ( in_usa? )
      "(#{region})"
    end
  end

  def location_country_of_region_parenthetical
    if not_in_usa?
      "(#{country})"
    end
  end

  # SHOW_PLACE

  def show_price_tier
    price_tier
  end

  def show_price_note
    price_note
  end

  def show_place_photo_gallery
    "<div class='photos-gallery' style='background-image: url(#{image.url})'}></div><div class='photos-caption'>Photo Credit: #{link_to image.source, image.source_url, :title => 'original photo'}</div>".html_safe
  end

end