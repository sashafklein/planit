class UserMailer < ActionMailer::Base
  default from: "New User <newuser@plan.it>"

  def welcome_waitlist(user, password)
    @user = user
    mail(to: user.email, subject: "Thanks for Signing up for Planit Beta!")
  end

  def welcome_invited(user, password) #NEEDSFOLLOWUP
    @user = user
    @password = password
    mail(to: user.email, subject: "Welcome to Planit Beta!", password: password)
  end

end
