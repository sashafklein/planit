module UsualSuspects

  # USUAL SUSPECTS LISTS (CSS)

  def heading_usual_suspects
    attemts = [
      "h1",
      ".header",
      "#header",
      ".heading",
      "#heading",
      ".HEADER",
      "#HEADER",
      ".HEADING",
      "#HEADING",
    ]
  end

  def meta_name_usual_suspects
    attempt = [
      "meta[property='og:title']",
      "meta[itemprop='name']",    
    ]
  end

  def details_name_usual_suspects
    attempts = [
      "[itemprop='name']",
      "[itemprop='title']",  
      "[property='v:name']",
      "[property='v:title']",
    ]
  end

  def full_address_usual_suspects
    attempts = [
      "[property='v:contact']",          
      "[property='v:address']",          
      ".contact",
      "#contact",
      ".contact-info",
      "#contact-info",
      ".contact_info",
      "#contact_info",
      ".contact-info",
      "#contact-info",
      "adr",
      ".adr",
      "#adr",
      "adresse",
      ".adresse",
      "#adresse",
      "address",
      ".address",
      "#address",
      ".address-info",
      "#address-info",
      ".address_info",
      "#address_info",
      ".address-info",
      "#address-info",
      "location",
      ".location",
      "#location",
      ".propertyAddress",
      "#propertyAddress",
      ".property-address",
      "#property-address",
      ".property_address",
      "#property_address",
      "[itemprop='contact']",
      "[itemprop='contact-info']",
      "[itemprop='contact_info']",
      "[itemprop='contactinfo']",
      "[itemprop='address']",
      "[itemprop='address-info']",
      "[itemprop='address_info']",
      "[itemprop='addressinfo']",
    ]
  end

  def street_address_usual_suspects
    attempts = [
      "meta[property='street_address']",
      "[itemprop='streetAddress']",
      "[itemprop='street_address']",
      "[itemprop='street-address']",
      "[itemprop='streetaddress']",
      "[property='v:streetAddress']",
      "[property='v:street_address']",
      "[property='v:street-address']",
      "[property='v:streetaddress']",
    ]
  end

  def locality_usual_suspects
    attempt = [
      "meta[property='locality']",
      "meta[property='city']",
      "[itemprop='locality']",
      "[itemprop='city']",
      "[property='v:locality']",
      "[property='v:city']",
    ]
  end

  def region_usual_suspects
    attempt = [
      "meta[property='region']",
      "meta[property='state']",
      "[itemprop='region']",
      "[itemprop='state']",
      "[property='v:region']",
      "[property='v:state']",
    ]
  end

  def country_usual_suspects
    attempts = [
      "meta[property='country']",
      "meta[property='addressCountry']",
      "meta[property='country_name']",
      "meta[property='countryName']",
      "[itemprop='countryName']",
      "[itemprop='country_name']",
      "[itemprop='country-name']",
      "[itemprop='countryname']",
      "[itemprop='country']",          
      "[itemprop='addressCountry']",          
      "[itemprop='address_country']",          
      "[itemprop='address-country']",          
      "[property='v:countryName']",
      "[property='v:country_name']",
      "[property='v:country-name']",
      "[property='v:countryname']",
      "[property='v:country']",          
      "[property='v:addressCountry']",          
      "[property='v:address_country']",          
      "[property='v:address-country']",          
    ]
  end

  def postal_code_usual_suspects
    attempts = [
      "meta[property='postal_code']",
      "meta[property='postalCode']",
      "meta[property='zip_code']",
      "meta[property='zipCode']",
      "meta[property='zipcode']",
      "[itemprop='postalCode']",
      "[itemprop='postal_code']",
      "[itemprop='postal-code']",
      "[itemprop='postalcode']",
      "[itemprop='zipCode']",          
      "[itemprop='zip_code']",          
      "[itemprop='zip-code']",          
      "[itemprop='zipcode']",          
      "[property='v:postalCode']",
      "[property='v:postal_code']",
      "[property='v:postal-code']",
      "[property='v:postalcode']",
      "[property='v:zipCode']",
      "[property='v:zip_code']",
      "[property='v:zip-code']",
      "[property='v:zipcode']",
    ]    
  end

  def map_link_src_usual_suspects # link-href or imgs-src contain
    attempts = [
      "www.google.com/maps/", # e.g. https://www.google.com/maps/place/124+Columbus+Ave/@37.7967858,-122.4048005,17z/data=!3m1!4b1!4m2!3m1!1s0x808580f4dc5c4831:0x1bea4997be9969cf
      "maps.google.com/maps?", # e.g. http://maps.google.com/maps?f=q&source=s_q&hl=en&geocode=&q=contigo+1320+castro+street,+san+francisco,+ca+94114&sll=37.0625,-95.677068&sspn=62.870523,55.898438&ie=UTF8&z=17&iwloc=A
    ]
  end

  def map_container_usual_suspects # link-href or imgs-src contain
    attempts = [
      ".static_map", 
      "#static_map", 
      ".mapbox", 
      "#mapbox", 
    ]
  end

  def latitude_usual_suspects
    attempts = [
      "[itemprop='lat']",
      "[itemprop='latitude']",
      "[property='v:lat']",
      "[property='v:latitude']",
      "[data-lat]",
      "[data-latitude]",
    ]
  end

  def longitude_usual_suspects
    attempts = [
      "[itemprop='lon']",
      "[itemprop='lng']",
      "[itemprop='long']",
      "[itemprop='longitude']",
      "[property='v:lon']",
      "[property='v:lng']",
      "[property='v:long']",
      "[property='v:longitude']",
      "[data-lon]",
      "[data-lng]",
      "[data-long]",
      "[data-longitude]",
    ]
  end

  def phone_usual_suspects
    attempts = [
      "meta[property='phone']",
      "meta[property='phone_number']",
      "meta[property='phoneNumber']",
      "[itemprop='telephone']",
      "[itemprop='phone']",
      "[itemprop='phone_number']",
      "[itemprop='phone-number']",
      "[itemprop='phoneNumber']",          
      "[itemprop='mobile']",          
      "[property='v:telephone']",
      "[property='v:phone']",
      "[property='v:phone_number']",
      "[property='v:phone-number']",
      "[property='v:phoneNumber']",
      "[property='v:mobile']",
    ]
  end

  def article_usual_suspects
    list = [
      "article",
      ".article-body",
      "#article-body",
      ".story-body",
      "#story-body",
      ".main-text",
      "#main-text",
      ".main",
      "#main",
      ".story",
      "#story",
      ".article",
      "#article",
      ".article-content",
      "#article-content",
      ".story-content",
      "#story-content",
      ".main-content",
      "#main-content",
    ]
  end

  def image_usual_suspects
    list = [
      "ul.slides",
      ".gallery",
      "#gallery",
      ".large-image-wrapper",
      "#large-image-wrapper",
      ".large-image-viewport",
      "#large-image-viewport",
      ".screen-gallery",
      "#screen-gallery",
      ".flex-viewport",
      "#flex-viewport",
      ".hero",
      "#hero",
    ]
  end

  # USUAL SUSPECTS (TEXT)

  def details_box_usual_textspects
    list = [
      "if you go",
      "more details",
      "when you go",
      "info:",
    ]
  end

  def prohibited_link_to_name_text_list 
    list = [
      "Coming to",
      "coming to",
      "Open Table",
      "OpenTable",
      "TripAdvisor",
      "Trip Advisor",
      "Yelp",
      "Google",
      "Yahoo",
      "Review",
      "review",
      "Reservations",
      "reservations",
      "reserve",
      "Reserve",
      "Reserve a table",
      "reserve a table",
      "Reserve a room",
      "reserve a room",
    ]
  end

  def prohibited_link_to_name_domains
    list = [
      "wikipedia",
      "answers",
      "quora",
      "dictionary",
    ]
  end

  def prohibited_strong_results 
    list = [
      "The Bite",
      "Where",
      "When",
      "Extra",
      "Cost",
      "Open",
      "Hours",
    ]
  end

  # USUAL SUSPECT FUNCTIONS

  def get_usual_suspect_text(list, nokogiri_page=nil)
    if !nokogiri_page
      nokogiri_page = page unless !respond_to?(:page)
    end
    list.each do |attempt|
      if object = nokogiri_page.css(attempt).first
        if object.attribute("content")
          return trim( object.attribute("content").value )
        elsif attempt.scan(/\A\[([^']*)\]\Z/).flatten.first && object.attribute(attempt.scan(/\A\[([^']*)\]\Z/).flatten.first)
          return trim( de_tag( breakline_to_space( object.attribute.value ) ) )
        elsif object.text && object.text.length > 0
          return trim( de_tag( breakline_to_space( object.text ) ) )
        end
      end
    end
    return nil
  end

  def get_usual_suspect_html(list, nokogiri_page=nil)
    if !nokogiri_page
      nokogiri_page = page unless !respond_to?(:page)
    end
    list.each do |attempt|
      if object = nokogiri_page.css(attempt).first
        if object.inner_html && object.inner_html.length > 0
          return trim( breakline_to_space( object.inner_html ) )
        elsif object.attribute("content")
          return trim( object.attribute("content").value )
        elsif attempt.scan(/\A\[([^']*)\]\Z/).flatten.first && object.attribute(attempt.scan(/\A\[([^']*)\]\Z/).flatten.first)
          return trim( de_tag( breakline_to_space( object.attribute.value ) ) ) 
        end
      end
    end
    return nil
  end

  # USUAL TEXTSPECT FUNCTIONS

  def get_usual_textspect_html(list, nokogiri_page=nil)
    if !nokogiri_page
      nokogiri_page = page unless !respond_to?(:page)
    end
    list.each do |attempt|
      cased_attempts = [attempt.capitalize, attempt.titleize, attempt.downcase, attempt.upcase]
      cased_attempts.each do |cased_attempt|
        if object = nokogiri_page.css("strong:contains('#{cased_attempt}')").last
          return get_content_from_textspect_object(object, cased_attempt)
        elsif object = nokogiri_page.css("b:contains('#{cased_attempt}')").last
          return get_content_from_textspect_object(object, cased_attempt)
        elsif object = nokogiri_page.css("p:contains('#{cased_attempt}')").last
          return get_content_from_textspect_object(object, cased_attempt)
        end
      end
    end
    return nil
  end

  def get_content_from_textspect_object(object, cased_attempt)
    if object.children && object.children.length > 1
      # return object.children.inner_html
      return object.inner_html
    elsif object.next_element && object.next_element.text
      if object.next_element.text.length > 100
        return object.next_element.inner_html
      end
    else
      parent = parent_until_children(object)
      return parent.split(cased_attempt)[1]
    end
  end

end
