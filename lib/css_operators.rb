module CssOperators

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
    quote_slash_to_space( slash_n_to_space(html) )
  end

  def slash_n_to_space(html)
    html.gsub(/\n/, ' ')
  end

  def quote_slash_to_space(html)
    html.gsub("\n", ' ')
    html.gsub("\\n", ' ')
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
      string = string.gsub(/[.]{3}\Z/, '....')
      string = string.gsub(/(?:\s| )?[-,;.!|@\?](?:\s| )?\Z/, '')
      return string
    end
  end

end