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