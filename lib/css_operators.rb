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
    html.gsub(/\n/, ' ') ; rescue ; html
  end

  def quote_slash_to_space(html)
    html.gsub("\n", ' ') ; rescue ; html
  end

  def regex_split_without_loss(string_or_array, split_term)
    add_back = string_or_array.scan(split_term).flatten
    add_to = string_or_array.split(split_term).reject(&:blank?)
    # binding.pry
    if add_back && add_to && add_back.length > 0 && add_to.length > 0
      0.upto(add_to.length - 1).each do |i|
        add_to[i] = add_back[i] + add_to[i]
      end
      return add_to
    else
      return nil
    end
  end

  def text_selector(selector)
    if (sel = css(selector)).any?
      text = sel.inner_html
        .gsub(/\<\/*[p]\>/, "\n")
        .gsub(/\<\/*[br]\>/, "\n")
        .gsub(/\&[l][t]\;(?:.|\n)*?\&[g][t]\;/, '')
      de_tag( text )
    else
      nil
    end
  end
    
  def de_tag(html)
    if html && html.length > 0
      html.gsub(/<(?:.|\n)*?>/, '')
    end
  end

  def trim(html)
    if html && html.length > 0
      html = html.gsub(/(\r\n|\n|\r)/, '')
          .gsub(/( {2,})/, ' ')
          .gsub(/^\s+|\s+$/, '')
          .gsub(/\s+/, ' ')
          .gsub(/(\t)/, '')
      URI.unescape(html)
    end
  end
end