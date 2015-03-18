class AdminMailerPreview < ActionMailer::Preview
  def bookmarklet_failure
    AdminMailer.bookmarklet_failure(User.first.id, 'nytimes.com')
  end

  def new_feedback
    AdminMailer.new_feedback(PageFeedback.first)
  end

  def failed_feedback
    AdminMailer.failed_feedback(NpsFeedback.first.id, User.first.id, 'localhost:3000/whatever')
  end

  def notify_of_signup
    AdminMailer.notify_of_signup(User.first)
  end
end