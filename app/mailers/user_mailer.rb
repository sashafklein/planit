class UserMailer < ActionMailer::Base
  default from: "New User <newuser@plan.it>"

  def welcome_beta(user)
    @user = user
    mail(to: user.email, subject: "Welcome to Planit Beta!")
  end

end
