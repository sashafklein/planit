module ScraperOperators

  # OPERATIONS

  def before_divider(string)
    trim(
      string
        .try( :gsub, /[ ]{3}.*/, '' )
        .try( :gsub, / \- .*/, '' )
        .try( :gsub, /\:.*/, '' )
        .try( :gsub, /\;.*/, '' )
        .try( :gsub, /\/.*/, '' )
        .try( :gsub, /\|.*/, '' )
    )
  end

  def remove_plan_name_fluff(text)
    text = text.gsub(/\s*on TripAdvisor\s*\Z/, '') unless !text
    text = text.gsub(/\s*[|] Frommer[']s\s*\Z/, '') unless !text
    text = text.gsub(/\s*[-] NYTimes.com\s*\Z/, '') unless !text
    text = text.gsub(/\A\s*JOURNEYS [-]\s*/, '') unless !text
    text = text.gsub(/\s*[-] Stay.com\s*\Z/, '') unless !text
  end
  
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
    return nil unless selector = list.find{ |sel| css(sel).any? }
    
    @scrape_container = ( selector == 'article' ? css(selector) : css(selector).first )
  end

  def illegal_content # DOUBLE \\
    [
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
    @scrape_content = CGI.unescape( scrape_container(@scrape_target).inner_html )
                        .gsub(/\s\s+/, "  ") #maximum 2 spaces
                        .gsub(/\n/, '').gsub(/[\u00AD]/, '').gsub(/\"/, "'")

    illegal_content.each{ |reg| @scrape_content.gsub!(%r!#{ reg }!, '') }
    
    @scrape_content
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
      return { is: guesses.compact.uniq.first, confidence: 1 }
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
        return { is: top_guess, confidence: confidence }
      end
    end
    return { is: nil, confidence: 0 }
  end

  def dominant_pick(guesses)
    top_score = 0
    guesses = guesses.sort_by! { |s| -s.length }
    guesses.compact.uniq.each do |guess|
      score = 0
      guesses.compact.each do |against|
        if guess.downcase.include?(against.downcase)
          score += 1
        end
      end
      return guess if score > top_score
    end
    return nil
  end

  def unhex(string)
    string.gsub(/\\x26amp\;/, "&")
          .gsub(/\\x26/, "&")
          .gsub(/\&\#39\;/, "'")
  end

  def cased(string)
    return [] unless string
    [string, string.titleize, string.capitalize, string.downcase, string.upcase]
  end

end
