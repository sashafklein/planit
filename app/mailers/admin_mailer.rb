class AdminMailer < ActionMailer::Base
  default from: "Notifier <notifier@plan.it>"
  default to: "Planit <hello@plan.it>"

  def bookmarklet_failure(user_id, url)
    mail_no_layout( subject: 'Bookmarklet Failure', content: "User ID: #{user_id}\n\nURL: #{url}" )
  end

  def new_feedback(page_id)
    page = PageFeedback.find(page_id)
    mail_no_layout(subject: "New Feedback", content: "User ID: #{page.user_id}\n\nDetails: #{page.details}\n\nNPS ID: #{page.nps_feedback_id}")
  end

  def failed_feedback(nps_id, current_user_id, url)
    mail_no_layout(subject: "Feedback failed to save!", content: "User ID: #{current_user_id}\n\nNPS ID: #{nps_id}\n\nURL: #{url}")
  end

  def notify_of_signup(user)
    list = [:id, :first_name, :last_name, :email, :role].map do |attr|
      "<li>#{attr.to_s.capitalize}: #{user[attr]}</li>"
    end
    mail_no_layout({subject: "New Planit #{user.role.capitalize} Sign up!", content: "<ul>#{list}</ul>"})
  end

  private

  def mail_no_layout(subject:, content: '', overrides: {})
    mail( {subject: subject}.merge(overrides) ) do |format|
      format.html { render text: content }
    end
  end
end
