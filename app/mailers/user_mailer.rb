class UserMailer < BaseMailer
  default from: hello
  default bcc: sent

  layout 'layouts/mailer.html.haml'

  def welcome_waitlist(atts)
    include_inline_images
    @user = User.new(atts)
    roadie_mail(to: @user.email, subject: "Thanks for Signing up for Planit Beta!")
  end

  def welcome_invited(atts, inviter_name=nil)
    include_inline_images
    @user = User.new(atts)
    [admin, @user.email].each do |recipient|
      roadie_mail(to: recipient, subject: inviter_name ? "#{inviter_name} invited you to Planit!" : "Welcome to Planit Beta!")
    end
  end

  def share_love(share_id:, email: nil)
    share = Share.find(share_id)
    @object = share.object
    @sharer = share.sharer
    @user = share.sharee || User.new(email: email)
    @url = URI.decode( share.url + ( share.url.include?('?') ? '&' : '?' ) + "referred=#{ share.sharee ? 'registered' : 'new' }&email=#{@user.email}&share_id=#{share_id}" )
    @notes = share.notes
    @images = get_images(@object)
    share.email_title
    include_inline_images(@images)

    roadie_mail(from: @sharer.email, to: @user.email, subject: share.email_title)
  end

  private

  def get_images(object)
    return [] unless object.try(:images)
    if object.class.to_s == "User"
      # Places -> maybe include captured image of map of filtered places, bounded, formatted to 600x600?
      # Guides -> maybe include captured image of cluster of filtered guides, formatted to 600x600?
      # See -> https://github.com/csquared/IMGKit
      return []
    else
      return object.images.pluck(:url).first(4) || []
    end    
  end

end
