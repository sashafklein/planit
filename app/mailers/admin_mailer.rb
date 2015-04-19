class AdminMailer < BaseMailer
  default from: "Notifier <notifier@plan.it>"
  default to: "Planit <hello@plan.it>"

  layout 'layouts/mailer'

  def bookmarklet_failure(user_id, url)
    include_inline_images
    @user_id, @url = user_id, url
    roadie_mail( subject: 'Bookmarklet Failure' )
  end

  def new_feedback(page_id)
    include_inline_images
    @page = PageFeedback.find_by(id: page_id) || PageFeedback.new
    roadie_mail( subject: "New Feedback" )
  end

  def failed_feedback(nps_id, current_user_id, url)
    include_inline_images
    @nps_id, @current_user_id, @url = nps_id, current_user_id, url
    roadie_mail( subject: "Feedback failed to save!" )
  end

  def notify_of_signup(user)
    include_inline_images
    @user = user
    roadie_mail( subject: "New Planit #{user.role.capitalize} Sign up!" )
  end

  def report_error(details)
    include_inline_images
    @details = details
    roadie_mail( subject: "An error occurred!" )
  end

end
