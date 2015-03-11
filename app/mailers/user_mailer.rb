class UserMailer < ActionMailer::Base
  default from: "New User <newuser@plan.it>"

  layout 'layouts/mailer.html.haml'

  def welcome_waitlist(user)
    attachments.inline['logo_name_only_white.png'] = File.read("#{Rails.root}/app/assets/images/logo_name_only_white.png")
    attachments.inline['logo_only_white.png'] = File.read("#{Rails.root}/app/assets/images/logo_only_white.png")
    @user = user
    mail(to: user.email, subject: "Thanks for Signing up for Planit Beta!")
  end

  def welcome_invited(user, password) #NEEDSFOLLOWUP
    attachments.inline['logo_name_only_white.png'] = File.read("#{Rails.root}/app/assets/images/logo_name_only_white.png")
    attachments.inline['logo_only_white.png'] = File.read("#{Rails.root}/app/assets/images/logo_only_white.png")
    @user = user
    @password = password
    mail(to: user.email, subject: "Welcome to Planit Beta!", password: @password)
  end

  # def share_love(user, url, title, note, recipient)
  #   @user = user, @url = url, @title = title, @note = note
  #   mail(from: @user.email, to: recipient, subject: "#{@title} from #{@user.first_name}", url: @url, note: @note)
  # end

end
