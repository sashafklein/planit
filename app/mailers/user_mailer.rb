class UserMailer < BaseMailer
  default from: hello
  default bcc: sent
  add_template_helper(ApplicationHelper)

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

  # def share_love(share_id:, email: nil)
  #   share = Share.find(share_id)
  #   @object = share.obj
  #   @sharer = share.sharer
  #   @user = share.sharee # || User.new(email: email)
  #   # @url = URI.decode( share.url + ( share.url.include?('?') ? '&' : '?' ) + "referred=#{ share.sharee ? 'registered' : 'new' }&email=#{@user.email}&share_id=#{share_id}" )
  #   @notes = share.notes
  #   @images = get_images(@object)
  #   include_inline_images(@images)

  #   roadie_mail(from: @sharer.email, to: @user.email, subject: share.email_title)
  # end

  def share_plan(share_id:, email:)
    share = Share.find(share_id)
    @plan = share.obj
    @items = @plan.items.includes( mark: :place )
    @images = plan_image_hash( @plan )
    # include_inline_images( @images.map{ |k, v| [ v[:image], v[:icon] ] }.compact.uniq.flatten )
    include_inline_images( [] )
    @sharer = share.sharer
    @sharee = User.where( email: email ).first_or_initialize
    @url = plan_url( @plan, {referred: ( @sharee.persisted? ? 'registered' : 'new' ), email: email, share_id: share_id} )
    @notes = share.notes
    roadie_mail(to: @sharee.email, subject: share.email_title)
  end

  private

  def plan_image_hash( plan )
    hash = {}
    plan.items.each do |i| 
      hash[i.id.to_s] = { image: sm_img( i ), icon: no_bg_icon( i ) }
    end
    hash
  end

  def no_bg_icon( item )
    item.mark.place.foursquare_icon.gsub( '_bg_64', "_32" )
  end

  def sm_img( item )
    item.image.try( :url ).try( :gsub, /\/\d*[x]\d*\//, "/69x69/" )
  end

end
