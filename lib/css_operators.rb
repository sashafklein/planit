module CssOperators

  # USUAL SUSPECTS LISTS

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

  def map_usual_suspects # ADD OTHER MAP SERVICES? BING? MAPBOX?
    attempts = [
      "www.google.com/maps/", # e.g. https://www.google.com/maps/place/124+Columbus+Ave/@37.7967858,-122.4048005,17z/data=!3m1!4b1!4m2!3m1!1s0x808580f4dc5c4831:0x1bea4997be9969cf
      "maps.google.com/maps?", # e.g. http://maps.google.com/maps?f=q&source=s_q&hl=en&geocode=&q=contigo+1320+castro+street,+san+francisco,+ca+94114&sll=37.0625,-95.677068&sspn=62.870523,55.898438&ie=UTF8&z=17&iwloc=A
    ]
  end

  def latitude_usual_suspects
    attempts = [
      "[itemprop='lat']",
      "[itemprop='latitude']",
      "[property='v:lat']",
      "[property='v:latitude']",
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

  # USUAL SUSPECT FUNCTIONS

  def get_usual_suspect_text(list)
    list.each do |attempt|
      if object = page.css(attempt).first
        if object.attribute("content")
          return trim( object.attribute("content").value )
        elsif object.text && object.text.length > 0
          return trim( de_tag( breakline_to_space( object.text ) ) )
        end
      end
    end
    return nil
  end

  def get_usual_suspect_html(list)
    list.each do |attempt|
      if object = page.css(attempt).first
        if object.attribute("content")
          return trim( object.attribute("content").value )
        elsif object.inner_html && object.inner_html.length > 0
          return trim( de_tag( breakline_to_space( object.inner_html ) ) )
        end
      end
    end
    return nil
  end

  # ERRATA

  def null_phone_text 
    list = [
     "telephone number",
     "phone number",
     "fax number",
     "international number",
     "telephone",
     "télephone",
     "telefon",
     "telefón",
     "tel",
     "tél",
     "phone",
     "mobile",
     "international",
     "toll free",
     "fax",
    ]
  end

  def null_map_text
    list = [
      "maps & directions",
      "map & directions",
      "maps",
      "mapa",
      "map",
      "directions",
      "direcciones",
    ]
  end

  def null_other_text
    list = [
      "[(].*reservations.*[)]",
      "[(].*reserve.*[)]",
      "[(].*click.*[)]",
      "[(].*online.*[)]",
      "[(].*follow.*[)]",
      "reservations",
      "reserve",
      "click for",
      "click",
      "online",
      "follow",
      "contact",
    ]
  end 

  def trim_after
    list = [
      "For media ",
    ]
  end

  # FUNCTIONS

  def clean_up_to_start_of_map_query(string)
    # delete the before-string junk
    string = string.gsub(/.*\.com\/maps/, '') unless !string
    string = string.gsub(/.*\/place\//, '') unless !string
    string = string.gsub(/.*[qQ]\=/, '')
    # clean up after string
    string = string.gsub(/\+\+.*/, '') unless !string
    string = string.gsub(/\/\@.*/, '') unless !string
    string = string.gsub(/\&.*/, '') unless !string
    return query = string
  end

  def find_query_name_in_map_string(string)
    query = clean_up_to_start_of_map_query(string)
    query = fix_url_spacing(query)
    # take out address starting with numbers
    query = query.gsub(/\d+ (?:\w|\d+).*/, '') unless !query
    query = query.titleize unless !query
    return trim( query )
  end

  def find_query_address_in_map_string(string, name_to_remove=nil)
    query = clean_up_to_start_of_map_query(string)
    query = fix_url_spacing(query)
    query = query.downcase.gsub(/\A(?:#{name_to_remove.downcase})/, '') unless !query # take out venue name
    query = query.titleize unless !query
    return trim( query )
  end

  def fix_url_spacing(string)
    string = string.gsub("+", " ") unless !string
    string = string.gsub("%20", " ") unless !string
    string = string.gsub("%2C", ",") unless !string
    return trim( string )
  end

  def find_scripts_inner_html(page_to_search)
    page_to_search.inner_html.scan(/<script(?:\s[^>]*)?\>(?:\s*\n\s*)?((?:\n|.)*?)(?:\s*\n\s*)?\<\/script\>/)
  end

  def split_by(selectors, split_array)
    Array(selectors).each do |selector|
      
      if ( node = css(selector) ).any?
        split_array.each do |split_by_element|
          splitter, index = split_by_element
          if node.inner_html.include?( splitter )
            return split(node, split_by_element.first, split_by_element.last)
          end
        end
      end

    end
  end

  def split(node, splitter, index)
    if node && node.length > 0
      split_array = node.inner_html.split( splitter )
      split_array[index]
    end
  end

  def breakline_to_space(html)
    quote_slash_to_space( slash_n_to_space( pbr_to_space( html) ) )
  end

  def slash_n_to_space(html)
    html.gsub(/(?:\n|\r|\t)/, ' ')
  end

  def pbr_to_space(html)
    html.gsub(/\<(?:br|p)[^>]*\>/, ' ')
  end

  def quote_slash_to_space(html)
    html.gsub("\n", ' ')
    html.gsub("\\n", ' ')
    html.gsub("\r", ' ')
    html.gsub("\\r", ' ')
  end

  def regex_split_without_loss(string_or_array, split_term)
    add_back = string_or_array.scan(split_term).flatten
    add_to = string_or_array.split(split_term).reject(&:blank?)
    if add_back && add_to && add_back.length > 0 && add_to.length > 0
      0.upto(add_to.length - 1).each do |i|
        add_to[i] = add_back[i] + add_to[i]
      end
      return add_to
    else
      return nil
    end
  end

  def regex_split_without_loss_clean_before(string_or_array, split_term)
    add_back = string_or_array.scan(split_term).flatten
    add_to = string_or_array.split(split_term).reject(&:blank?)
    add_to.delete_at(0)
    if add_back && add_to && add_back.length > 0 && add_to.length > 0
      0.upto(add_to.length - 1).each do |i|
        add_to[i] = add_back[i] + add_to[i]
      end
      return add_to
    else
      return nil
    end
  end

  def first_css_match(array)
    array.each do |attempt|
      if result = page.css(attempt).first 
        return result
      end
    end
    return nil
  end

  def find_lat_lon_string_in_script(string)
    string.scan(find_lat_lon_regex).flatten.first
  end

  def de_tag(html)
    if html
      html.gsub(/<(?:.|\n)*?>/, '')
    end
  end

  def trim(html)
    if html && html.length > 0
      string = URI.unescape(html)
      string = string.gsub(/(\r\n|\n|\r)/, '')
      string = string.gsub(/( {2,})/, ' ')
      string = string.gsub(/^\s+|\s+$/, '')
      string = string.gsub(/\s+/, ' ')
      string = string.gsub(/(\t)/, '')
      string = string.gsub(/[.]{3}\Z/, '....') # prep elipses for end punctuation removal (below)
      string = string.gsub(/(?:\s| )?[-,;.!|@\?](?:\s| )?\Z/, '')
      return string
    end
  end

  def delete_items_from_array_case_insensitive(array_of_deletion_terms, array_to_delete_from)
    array_of_deletion_terms.each do |e|
      array_to_delete_from.delete(e.upcase)
      array_to_delete_from.delete(e.downcase)
      array_to_delete_from.delete(e.capitalize)
      array_to_delete_from.delete(e.titleize)
    end
  end

  def clean_address_box(html)
    if html && html.length > 0
      details = URI.unescape( html )
      details = breakline_to_space( details ) unless !details
      details = details.gsub(/(?:#{quote_thread}|\\#{quote_thread}|\')/, "'") unless !details
      details = details.gsub(/(?:\n|\\n)/, '') unless !details
      details = de_tag( details ) unless !details
      details = details.gsub(/#{case_desensitize_and_pluralize_array(null_phone_text)}[.]?\s*[-:.]?/, '') unless !details
      details = details.gsub(/#{case_desensitize_and_pluralize_array(null_map_text)}/, '') unless !details
      details = details.gsub(/#{case_desensitize_array(null_other_text)}/, '') unless !details
      details = details.gsub(/(?:#{trim_after.join('|')}).*/, '') unless !details
      postal_code = details.scan(/(?: |\,)\d{5}\d?(?:[- ]\d{4})?(?: |\,|\Z)/).flatten.first
      if postal_code && postal_code.length > 0
        details = details.gsub("#{postal_code}", '________')
        if !@postal_code
          @postal_code = trim( postal_code )
        end
      end
      if @phone
        details = details.gsub("@phone}", '') unless !details
      elsif @phone = trim( details.scan(/(#{phone_number_thread})/).flatten.first )
        details = details.gsub("#{@phone}", '') unless !details
        details = details.gsub(/#{phone_number_thread}/, '') unless !details
      end
      details = details.gsub("________", postal_code) unless !details || !postal_code
      details = details.gsub(/(?: [;,.|] )/, '') unless !details
      details = details.gsub(/#{email_thread}/, '') unless !details
      return trim( details )
    end
  end

end