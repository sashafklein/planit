class Share < BaseModel

  is_polymorphic should_validate: false
  belongs_to :sharer, class_name: "User"
  belongs_to :sharee, class_name: "User"

  def self.save_and_send(sharer:, sharee:, url:, object: nil, notes:)
    atts = {sharer: sharer, sharee: sharee, url: url, object: object || find_object(url), notes: notes}
    atts.merge!({ sharee: nil }) unless sharee.persisted?

    if new_share = create(atts)
      AcceptedEmail.where(email: sharee.email).first_or_create!
      UserMailer.share_love(share_id: new_share.id, email: sharee.email).deliver_now
      return new_share
    end
  end

  # PRIVATE

  def email_title
    return "#{sharer.name} shared a page on Planit!" unless object
    
    case object.class.to_s
    when 'Place' then "A Planit Place from #{sharer.name}: #{object.name}"
    when 'Plan'  then "A Planit Guide from #{sharer.name}: #{object.name}"
    when 'User'  then "#{sharer.name} shared a page on Planit: #{ [extras.years, extras.filters, extras.subtype, extras.geographies].compact.join(" ") }"
    else "#{sharer.name} shared a page on Planit!"
    end
  end

  private

  def extras
    @extras ||= self.class.extras_hash(url)
  end

  def self.find_object(url)
    allowable_object_types = %w( places plans users )
    objects_in_url = UrlObjectParser.new(url).objects
    object = objects_in_url.find{ |c, id| allowable_object_types.include?(c.downcase.pluralize) }

    # Assumes a single object per share ( ie not guides/2043+3043+3801 )
    object ? object.first.constantize.find( object.last ) : nil
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
