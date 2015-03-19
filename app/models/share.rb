class Share < BaseModel

  is_polymorphic should_validate: false
  belongs_to :sharer, class_name: "User"
  belongs_to :sharee, class_name: "User"

  def self.save_and_send(sharer:, sharee:, url:, object:, notes:)
    if new_share = create(sharer: sharer, sharee: sharee, url: url, object: object, notes: notes)
      title = build_title( new_share.object, extras_hash(url) )
      UserMailer.share_love(share: new_share, title: title).deliver_now
      return self
    end
  end

  # PRIVATE

  def self.find_object(url)
    url_pieces = URI.parse(url).path.split("/") if URI.parse(url).path.split("/") != []
    return nil if !url_pieces.present? && url_pieces.length < 3

    allowable_object_types = %w( places plans users )
    object_type = url_pieces[1]
    if allowable_object_types.include?(object_type)
      if id_or_slug = url_pieces[2]
        # Assumes a single object per share ( ie not guides/2043+3043+3801 )
        class_name = object_type.singularize.camelize.constantize
        return find_object_in_db(class_name, id_or_slug)
      end
    end
    nil
  end

  def self.build_title(object, extras)
    if object.class.to_s == 'Place'
      object.name
    elsif object.class.to_s == 'Plan'
      [
      User.find( object.user_id ).name + "'s",
      "Guide:",
      object.name,
      extras.years,
      extras.filters,
      extras.geographies,
      ].compact.join(" ")
    elsif object.class.to_s == 'User'
      [
      object.name + "'s",
      extras.years,
      extras.filters,
      extras.subtype,
      extras.geographies,
      ].compact.join(" ")
    end
  end

  def self.extras_hash(url)
    extras = {}
    page_and_querystring = url.split("/").last.split("?")
    query = page_and_querystring.last.split("&").inject({}) { |hash, string| hash[string.split("=").first] = string.split("=").last; hash } if page_and_querystring.length == 2
    extras[:subtype] = page_and_querystring.first.capitalize
    extras[:years] = clean_query( query["y"] ) if query["y"].present?
    extras[:filters] = clean_query( query["f"] ) if query["f"].present?
    extras[:geographies] = "near " + clean_query( query["n"] ) if query["n"].present?
    # extras[:search] = " narrowed with " + clean_query( query["q"], true ) if query["q"].present?
    return extras.to_sh
  end

  def self.is_id?(id_or_slug)
    id_or_slug.to_i.to_s == id_or_slug
  end

  def self.find_object_in_db(class_name, id_or_slug)
    searcher = is_id?(id_or_slug) ? class_name : class_name.friendly
    searcher.find( id_or_slug )
  end

  def self.clean_query(query, quotes=false)
    URI.decode( query ).gsub("in_", '').split("+").to_sentence(last_word_connector: " & ")
  end

end
