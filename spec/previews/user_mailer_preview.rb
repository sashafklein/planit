class UserMailerPreview < ActionMailer::Preview

  def welcome_waitlist
    UserMailer.welcome_waitlist( User.first )
  end

  def welcome_invited
    UserMailer.welcome_invited( User.first, 'yourNewPassword!' )
  end

end