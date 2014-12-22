module ScraperOperators

  # OPERATIONS
  
  def calculate_rating(string, base=nil)
    if string && string.length > 0
      rate = string.scan(/.*?(\d+\.?\d*)(?: (?:out )?of (\d+\.?\d*))?.*?/).flatten.first.to_f
      unless base
        base = string.scan(/.*?(\d+\.?\d*)(?: (?:out )?of (\d+\.?\d*))?.*?/).flatten[1].to_f
      end
    end
    if rate && base
      return ( (rate.to_f * 100) / base ).round
    end
  end

  def remove_punc(string)
    string.scan(remove_final_punctuation_regex).first.first ; rescue ; string
  end

  def p_br_to_comma(string)
    string.gsub("<br>", ", ").gsub("<p>", ", ").gsub(",,", ",").gsub(", ,", ",") ; rescue ; nil
  end

  def scrape_container(list)
    return @scrape_container if @scrape_container
    selector = list.select{ |sel| css(sel).any? }.first
    @scrape_container = css(selector) if selector
  end

  def illegal_content # DOUBLE \\
    illegal_content_array = [
      "\\<div [^>]*class\\=\\'[^\\s']*ad\\s[^']*\\'\\>.*?\\<\\/div\\>",
      "\\<\\!\\-\\-.*?\\-\\-\\>",
      "\\<script(?:\\s|\\>).*?\\<\\/script\\>",
      "\\<style(?:\\s|\\>).*?\\<\\/style\\>",
      "\\<figure(?:\\s|\\>).*?\\<\\/figure\\>",
      "\\<div\\s[^>]*?(?:g\\-type\\_Inset|g\\-aiAbs)[^>]*?\\>.*?\\<\\/div\\>",
      "\\<meta\\s.*?\\>",
      "\\<[^<>]*?data-description\\=\\'[^<>]*?\\'[^<>]*?\\>",
      "\\<header(?:\\s|\\>).*?\\<\\/header\\>",
      "\\<nav(?:\\s|\\>).*?\\<\\/nav\\>",
      "\\<form(?:\\s|\\>).*?\\<\\/form\\>",
      "\\<span[^>]*trb_mainContent_copyright[^>]*\\>.*?\\<\\/span\\>",
      "\\<div[^>]*trb_mainContent_copyright[^>]*\\>.*?\\<\\/div\\>",
      "\\<span[^>]*trb_socialize[^>]*\\>.*?\\<\\/span\\>",
      "\\<div[^>]*trb_socialize[^>]*\\>.*?\\<\\/div\\>",
      "\\<span[^>]*trb_socialshare[^>]*\\>.*?\\<\\/span\\>",
      "\\<div[^>]*trb_socialshare[^>]*\\>.*?\\<\\/div\\>",
      # "\\<[^<>]*?story-meta\\=\\'[^<>]*?\\'[^<>]*?\\>",
    ]
  end

  def scrape_content
    return @scrape_content if @scrape_content
    @scrape_content = CGI.unescape( scrape_container(@scrape_target).first.inner_html )
    @scrape_content = @scrape_content.gsub(/\s\s+/, "  ") #maximum 2 spaces
    @scrape_content = @scrape_content.gsub(/\n/, '')
    @scrape_content = @scrape_content.gsub(/[\u00AD]/, '')
    @scrape_content = @scrape_content.gsub(/\"/, "'")
    0.upto(illegal_content.length - 1).each do |i|
      @scrape_content = @scrape_content.gsub(%r!#{illegal_content[i]}!, '')
    end
    return @scrape_content
  end

  def no_accents(string)
    if string && string.length > 0
      I18n.transliterate string
    end
  end

  def reject_long(string, max_words=10, max_chars=30)
    if string && string.length <= max_chars
      if string.split(" ").compact.length <= max_words
        return string
      end
    end
    return nil      
  end

  def top_pick(guesses, threshold=0.5)
    if guesses && guesses.compact.uniq.length == 1
      return [guesses.compact.uniq.first, 1]
    elsif guesses && guesses.compact.uniq.length > 1
      top = 0
      top_guess = ""
      guesses.compact.uniq.each do |guess|
        if guesses.select{ |e| e == guess }.length > top
          top = guesses.select{ |e| e == guess }.length 
          top_guess = guess
        elsif guesses.select{ |e| e == guess }.length == top
          # strict no-equals rule would be to un-comment the below
          # top_guess = ""
        end
      end
      confidence = (top.to_f / guesses.compact.length.to_f)
      if confidence > threshold
        return [top_guess, confidence]
      end
    end
    return []
  rescue ; nil
  end

  def dominant_pick(guesses)
    top_score = 0
    top_pick = nil
    guesses = guesses.sort_by! { |s| -s.length }
    guesses.compact.uniq.each do |guess|
      score = 0
      guesses.compact.each do |against|
        if guess.downcase.include?(against.downcase)
          score += 1
        end
      end
      if score > top_score
        return top_pick = guess 
      end
    end
    return nil
  end

  def unhex(string)
    string = string.gsub(/\\x26amp\;/, "&") unless !string
    string = string.gsub(/\\x26/, "&") unless !string
    string = string.gsub(/\&\#39\;/, "'") unless !string
  end

  def cased(string)
    if string
      return [string, string.titleize, string.capitalize, string.downcase, string.upcase]
    end
    return []
  end

end
