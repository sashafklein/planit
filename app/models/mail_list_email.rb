class MailListEmail < ActiveRecord::Base

  def user
    User.find_by(email: email)
  end

  def self.valid?(email)
    email.scan(Devise.email_regexp).flatten.first
  end

  def self.waitlist!(params)
    query = where(params.to_sh.only(:email, :first_name, :last_name).to_h)
    if query.any?
      return false
    else
      query.create!
      UserMailer.welcome_waitlist(params).deliver_later
      params[:email]
    end
  end
end
