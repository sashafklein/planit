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
    allowable_object_types = %w( places plans users )
    objects_in_url = UrlObjectParser.new(url).objects
    object = objects_in_url.find{ |c, id| allowable_object_types.include?(c.downcase.pluralize) }

    # Assumes a single object per share ( ie not guides/2043+3043+3801 )
    object ? object.first.constantize.find( object.last ) : nil
  end

  def self.build_title(object, extras)
    return "A page on Planit" unless object
    if object.class.to_s == 'Place'
      object.name
    elsif object.class.to_s == 'Plan'
      [User.find( object.user_id ).name + "'s Guide:",
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
    uri = URI.parse(url)
    query = CGI::parse(uri.query || '')
    { subtype: uri.path.split("/").last.try(:capitalize),
      years: clean_query( query["y"] ),
      filters: clean_query( query["f"] ),
      geographies: clean_query( query["n"] ) ? "near #{clean_query( query['n'] ) }" : nil
    }.to_sh
  end

  def self.clean_query(value, quotes=false)
    return if !value.present?
    URI.decode( value.first ).gsub("in_", '').split(",").to_sentence(last_word_connector: " & ")
  end

end
