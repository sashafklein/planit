class UserMailer < BaseMailer
  default from: "Planit <hello@plan.it>"

  layout 'layouts/mailer.html.haml'

  def welcome_waitlist(user)
    include_inline_images
    @user = user
    roadie_mail(to: user.email, subject: "Thanks for Signing up for Planit Beta!")
  end

  def welcome_invited(user, raw_reset_token)
    include_inline_images
    @user = user
    @token = raw_reset_token
    roadie_mail(to: user.email, subject: "Welcome to Planit Beta!")
  end

  def share_love(share:)
    @object = share.object
    @sharer = share.sharer
    @user = share.sharee
    @url = share.url
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
