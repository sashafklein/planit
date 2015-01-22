module QueryStrings

  def safe_to_delete
    list = [
      "ref",
      "_r",
      "pagewanted",
      "language",
      "sensor",
      "callback",
      "region",
      "text",
      "url",
      "return_to",
      "community_id",
      "via",
      "user",
      "label",
    ]
  end

  def trim_href_of_queries(href)
    if href.include?("?")
      base = href.scan(/\A(.*?)\?/).flatten.first
      reconstruct = []
      query = href.scan(/\A.*?\?(.*)/).flatten.first
      query.split("&").each do |q|
        reconstruct << q unless q.scan(/\A(?:#{safe_to_delete.join('|')})\=/).flatten.first
      end
      return base + "?" + reconstruct.join("&") unless !reconstruct.present?
    end
    return href
  end

end