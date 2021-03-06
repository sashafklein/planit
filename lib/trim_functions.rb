module TrimFunctions

  def trim(string)
    if string.present?
      URI.unescape(string)
        .try( :gsub, /(\r\n|\n|\r)/, ' ' )
        .try( :gsub, /([\\]{1,}\n|[\\]{2,}n|\\n)/, ' ' )
        .try( :gsub, /( {2,})/, ' ' )
        .try( :gsub, /^\s+|\s+$/, '' )
        .try( :gsub, /\s+/, ' ' )
        .try( :gsub, /\s([,:;.!|@\?])/, '\1' )
        .try( :gsub, /(\t)/, '' )
        .try( :gsub, /[.]{3}\Z/, '....' ) # prep elipses for end punctuation removal (below)
        .try( :gsub, /(?:\s| )?[,.!|@\?](?:\s| )?\Z/, '' ) #removed ';' in case of ASCII/HEX
        .try( :gsub, /\A[,:;.!|@\?](?:\s| )*/, '' )
        .try( :gsub, /(?:\A[ ]*|[ ]*\Z)/, '' )
        .try( :gsub, /(?:\A[-](?:[ ]|\s))/, '' )
    end
  end

  def de_tag(html)
    if html.present?
      html.try( :gsub, /<(?:.|\n)*?>/, '' )
    end
  end

end