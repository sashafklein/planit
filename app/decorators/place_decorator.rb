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

  def show_place_controls
    html = """
    <div class='place-controls'>
      <div class='place-control edit-place' id='tag' data-place-ids='#{[place.id]}'>
        <span class='place-control-hint'>Tag</span>
        <i class='fa fa-tag'></i>
      </div>   
      <div class='place-control edit-place' id='note' data-place-ids='#{[place.id]}'>
        <span class='place-control-hint'>Add Note</span>
        <i class='fa fa-pencil'></i>
      </div>   
      <div class='place-control edit-place' id='been' data-place-ids='#{[place.id]}'>
        <span class='place-control-hint'>Been</span>
        <i class='fa fa-check-square'></i>
      </div>   
      <div class='place-control edit-place' id='love' data-place-ids='#{[place.id]}'>
        <span class='place-control-hint'>Love</span>
        <i class='fa fa-heart'></i>
      </div>   
      <div class='place-control edit-place' id='save' data-place-ids='#{[place.id]}'>
        <span class='place-control-hint'>Save</span>
        <i class='fa fa-bookmark'></i>
      </div>   
    </div>
    """.html_safe 
  end

  def show_categories
    html = "<i class='#{meta_icon} place-page-meta-category'></i>"
    html += "<div class='place-page-category"
    html += if ( categories && categories.length > 0 ) then "'>#{categories.join(', ').titleize}</div>" else "gray '>Edit Destination Type</div>" end
    html.html_safe
  end

  def show_alt_names_in_parens
    if alt_names.any?
      content_tag :div, "(#{names.drop(1).join('), (')})", :class => 'address-info-line'
    end
  end

  def show_address_linked_to_directions
    h.link_to "https://maps.google.com?daddr=#{lat},#{lon}", :class => 'directions-link' do
      ''.html_safe + show_street_or_full_address + show_locality_zip_and_region + show_country
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
      phones.compact.each do |number|
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

  def next_image_script
    insert  = "<script type='text/javascript'> "
    insert +=   "var imageCount = 0; "
    insert +=   "var imageUrl = new Array(); "
    insert +=   "var imageCredit = new Array(); "
    insert +=   "var imageSource = new Array(); "
    insert +=   "function loadImages() { "
    images.each_with_index do |image, index|
      insert += "imageUrl[#{index}] = '#{image.url}'; "
      insert += "imageCredit[#{index}] = '#{image.source}'; "
      insert += "imageSource[#{index}] = '#{image.source_url}'; "
    end
    insert +=     "document.getElementById('gallery-number').innerHTML = '1'; "
    insert +=     "document.getElementById('gallery-image').style.backgroundImage = 'url(' + imageUrl[0] + ')'; "
    insert +=     "document.getElementById('gallery-link').innerHTML = imageCredit[0]; "
    insert +=     "document.getElementById('gallery-link').href = imageSource[0]; "
    insert +=   "}; "
    insert +=   "function nextImage() { "
    insert +=     "if (imageUrl.length > 0) { "
    insert +=       "if (imageCount + 1 < imageUrl.length) { "
    insert +=         "imageCount++; "
    insert +=       "} else { "
    insert +=         "imageCount = 0; "
    insert +=       "}; "
    insert +=       "document.getElementById('gallery-number').innerHTML = imageCount + 1; "
    insert +=       "document.getElementById('gallery-image').style.backgroundImage = 'url(' + imageUrl[imageCount] + ')'; "
    insert +=       "document.getElementById('gallery-link').innerHTML = imageCredit[imageCount]; "
    insert +=       "document.getElementById('gallery-link').href = imageSource[imageCount]; "
    insert +=     "};"
    insert +=   "};"
    insert +=   "window.onLoad = loadImages(); "
    insert += "</script>"
    return insert.html_safe
  end

  def show_hours
    html = ''
    if hours.any?
      %w( sun mon tue wed thu fri sat ).each do |day|
        if hours[day]
          html += "<div class='show-hours-line "
          html += "today" if day == today = Date.today.strftime('%a').downcase
          html += "'><i class='show-hours-day'>#{day.titleize}:</i> "
          windows = []
          hours[day].each do |window|
            windows << "#{Time.strptime(window.first, '%H%M').strftime('%l:%M%p').downcase} - #{Time.strptime(window.last, '%H%M').strftime('%l:%M%p').downcase}"
          end
          html += "#{windows.first}</div>" if windows.length == 1
          indenter = "</div><div class='show-hours-line indented'>"
          html += "#{windows.join(indenter)}</div>" if windows.length > 1
        else
          html += "<div class='show-hours-line'><i class='show-hours-day'>#{day.titleize}:</i> Closed</div>"
        end
      end
    end
    html.html_safe
  end

  def show_open_today
    if open_until.present?
      content_tag :div, "<i class='fa fa-clock-o'></i> Open #{formatted_open_until}".html_safe, :class => 'hours-availability-booking-content open-now'
    elsif open_again_at.present? 
      content_tag :div, "<i class='fa fa-clock-o'></i> Closed #{formatted_open_again_at}".html_safe, :class => 'hours-availability-booking-content closed-now'
    end
  end

  def show_reservations
    if reservations
      content_tag :div, :class => 'more-info-line ' do
        if reservations_link
          "<i class='fa fa-calendar place-show-icon'></i>Takes Reservations".html_safe
        else
          "<i class='fa fa-calendar place-show-icon'></i><a href='#{reservations_link}'>Make a Reservation</a>".html_safe
        end
      end
    else
      "<i class='fa fa-calendar place-show-icon'></i>No Reservations".html_safe
    end      
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
    if menu.present?
      content_tag :div, :class => 'more-info-line' do
        "<i class='fa fa-cutlery place-show-icon'></i> #{link_to menu, 'View Menu'}".html_safe
      end
    end
  end

  def show_has_wifi
    if wifi == true
      content_tag :div, :class => 'more-info-line' do
        "<i class='fa fa-wifi place-show-icon'></i> Has WiFi".html_safe
      end
    end
  end

  def show_foursquare_link
    if foursquare_id
      html = "<div class='more-info-line'>"
      html += "<i class='fa fa-foursquare place-show-icon'></i>"
      if foursquare_rating
        html += "<span class='rating "
        html += "green" if foursquare_rating > 8
        html += "yellow" if foursquare_rating < 8 && foursquare_rating > 6
        html += "red" if foursquare_rating <= 6
        html += "'><b>" + foursquare_rating.to_s + "</b>/10</span> rated on "
      end
      html += "<a href='http://www.foursquare.com/v/"+foursquare_id+"'>Foursquare</a>"
      html += " Venue Info" unless foursquare_rating
      html += "</div>"
      return html.html_safe
    end
  end

  def show_yelp_link
    if yelp_id
      html = "<div class='more-info-line'>"
      html += "<i class='fa fa-foursquare place-show-icon'></i>"
      if yelp_rating
        html += "<span class='rating "
        html += "five" if yelp_rating == 5
        html += "fourfive" if yelp_rating > 4.49 && yelp_rating < 5
        html += "four" if yelp_rating > 3.99 && yelp_rating > 4.5
        html += "threefive" if yelp_rating > 3.49 && yelp_rating > 4
        html += "three" if yelp_rating > 2.99 && yelp_rating > 3.5
        html += "twofive" if yelp_rating > 2.49 && yelp_rating > 3
        html += "two" if yelp_rating > 1.99 && yelp_rating > 2.5
        html += "onefive" if yelp_rating > 1.49 && yelp_rating > 2
        html += "one" if yelp_rating <= 1  && yelp_rating > 1.5
        html += "'> rated on "
      end
      html += "<a href='http://www.foursquare.com/v/"+yelp_id+"'>Yelp</a>"
      html += " Venue Info" unless yelp_rating
      html += "</div>"
      return html.html_safe
    end
  end

  # *** PRIVATE ***

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
    "<div class='photos-gallery'>#{show_photo}</div>#{show_photo_number}#{show_photo_caption}".html_safe
  end

  def show_photo
    "<a href='#' onClick='nextImage();'><div class='photos-gallery-image' id='gallery-image'></div></a>".html_safe
  end

  def show_photo_caption
    "<div class='photos-caption'>Photo Credit: <a href='#' id='gallery-link'>Loading</a></div>".html_safe
  end

  def show_photo_number
    if images.length > 1
      "<div class='photos-number'>[ <span id='gallery-number'>0</span> / #{images.length} ]</div>".html_safe
    end
  end

  def formatted_open_until
    if open_until
      html = ["until"]
      html << Time.strptime(open_until[:time], '%H%M').strftime('%l:%M%p').downcase
      html << open_until[:day].titleize if open_until[:day] != Date.today.strftime('%a').downcase
      html.join(" ")
    end
  end

  def formatted_open_again_at
    if open_again_at
      html = ["until"]
      html << Time.strptime(open_again_at[:time], '%H%M').strftime('%l:%M%p').downcase
      html << open_again_at[:day].titleize if open_again_at[:day] != Date.today.strftime('%a').downcase
      html << "today" if open_again_at[:day] == Date.today.strftime('%a').downcase
      html.join(" ")
    end
  end

end
