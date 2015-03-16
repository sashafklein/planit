module CssOperators

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
    Array(selectors).flatten.each do |selector|
      
      if ( node = css(selector) ).any?
        split_array.each do |split_by_element|
          splitter, index = split_by_element
          if node.inner_html.include?( splitter )
            return split(node, splitter, index)
          end
        end
      end

    end
    nil
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

  def trim_url(url)
    if url && url.length > 0
      string = url.gsub(/\s*/, '') unless !url
      string = string.gsub(/(?:\A[ ]*|[ ]*\Z)/, '') unless !string
      string = string.gsub(/[.&()]\Z/, '') unless !string
      return string
    end
  end

  def trim(html)
    if html && html.length > 0
      string = URI.unescape(html) unless !html
      string = string.gsub(/(\r\n|\n|\r)/, ' ') unless !string
      string = string.gsub(/([\\]{1,}\n|[\\]{2,}n|\\n)/, ' ') unless !string
      string = string.gsub(/( {2,})/, ' ') unless !string
      string = string.gsub(/^\s+|\s+$/, '') unless !string
      string = string.gsub(/\s+/, ' ') unless !string
      string = string.gsub(/\s([,:;.!|@\?])/, '\1') unless !string
      string = string.gsub(/(\t)/, '') unless !string
      string = string.gsub(/[.]{3}\Z/, '....') unless !string # prep elipses for end punctuation removal (below)
      string = string.gsub(/(?:\s| )?[,.!|@\?](?:\s| )?\Z/, '') unless !string #removed ';' in case of ASCII/HEX
      string = string.gsub(/\A[,:;.!|@\?](?:\s| )*/, '') unless !string
      string = string.gsub(/(?:\A[ ]*|[ ]*\Z)/, '') unless !string
      string = string.gsub(/(?:\A[-](?:[ ]|\s))/, '') unless !string
      return string
    end
  end

  def delete_items_from_array_case_insensitive(array_of_deletion_terms, array_to_delete_from)
    new_array = []
    array_to_delete_from.compact.each do |item|
      array_of_deletion_terms.compact.each do |deletion_term|
        item = trim( item.gsub(/(?:\A#{deletion_term}\Z|\A#{deletion_term.upcase}\Z|\A#{deletion_term.downcase}\Z|\A#{deletion_term.capitalize}\Z|\A#{deletion_term.titleize})\Z/, '') ) unless !item || !deletion_term
      end
      new_array << item
    end
    return new_array.compact
  end

  def delete_items_from_array(array_of_deletion_terms, array_to_delete_from)
    new_array = []
    array_to_delete_from.compact.each do |item|
      array_of_deletion_terms.compact.each do |deletion_term|
        item = trim( item.gsub(/(?:\A#{deletion_term}\Z)/, '') ) unless !item || !deletion_term
      end
      new_array << item
    end
    return new_array.compact
  end

  def page_count_beyond_threshold?(page, regex, threshold=25)
    if page = page.inner_html
      if count = page.scan(regex)
        if count.length > threshold
          return true
        end
      end
    end
    return false
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

  def parent_until_children(object)
    if object.inner_html
      while object.children.length < 2 do
        object = object.parent
      end
      return object.inner_html
    end
    return nil
  end

end