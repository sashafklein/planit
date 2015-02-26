class UserMailer < ActionMailer::Base
  default from: "New User <newuser@plan.it>"

  def notify_of_signup(user)
    @user = user
    recipients.each do |recipient|
      mail(to: recipient, subject: 'New Planit Sign up!')
    end
  end

  private

  def recipients
    [ "Notifications <notifications@plan.it>" ]
  end

end
