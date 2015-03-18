class AdminMailer < ActionMailer::Base
  default from: "Notifier <notifier@plan.it>"
  default to: "Planit <hello@plan.it>"

  layout 'layouts/mailer'

  def bookmarklet_failure(user_id, url)
    @user_id, @url = user_id, url
    mail( subject: 'Bookmarklet Failure' )
  end

  def new_feedback(page_id)
    @page = PageFeedback.find(page_id)
    mail( subject: "New Feedback" )
  end

  def failed_feedback(nps_id, current_user_id, url)
    @nps_id, @current_user_id, @url = nps_id, current_user_id, url
    mail( subject: "Feedback failed to save!" )
  end

  def notify_of_signup(user)
    @user = user
    mail( subject: "New Planit #{user.role.capitalize} Sign up!" )
  end

  def report_error(details)
    @details = details
    mail( subject: "An error occurred!" )
  end

end
