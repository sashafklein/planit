class User < BaseModel

  # validates :first_name, :last_name, presence: true

  enum role: { pending: 0, member: 1, admin: 2 }

  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :plans
  has_many :marks
  has_many :flags, as: :object
  has_many :nps_feedbacks
  has_many :page_feedbacks
  has_many :items, through: :marks

  has_many_polymorphic table: :one_time_tasks, name: :agent

  extend FriendlyId
  friendly_id :name, use: :slugged

  def casual_name
    first_name || email.gsub(/[@].*/, '')
  end

  def name
    [first_name, last_name].compact.join(" ")
  end

  def icon
    false
  end

  def marks_with_places
    marks.where.not( place_id: nil).order('updated_at DESC')
  end

  # INBOX MESSAGES

  def saves_to_review
    marks.where( place_id: nil ).includes(:place_options, :sources)
  end

  def shares_to_review
    Mark.where( id: Share.where( sharee: self, object_type: 'Mark' ).pluck(:object_id) )
  end

  def messages
    saves_to_review.count + shares_to_review.count
  end

  # INVITATION, STATUS

  def save_as(status, new_password=Devise.friendly_token.first(8))
    password = new_password if !self.encrypted_password.present?
    new_attrs = { role: status }.merge({
      password: password, password_confirmation: password, 
      reset_password_token: password, # set temp passcode as reset token
      sign_in_count: (0 if status == :member && status.to_s != role) # reset signincount if upgrading
    }.to_sh.reject_val(&:nil?))
    update_attributes( new_attrs )
    notify_signup() if self.persisted?
    return self
  end

  def tokened_email
    if reset_password_token.present?
      "?token=" + reset_password_token + "&email=" + email
    else
      ''
    end
  end

  # USER GUIDES LOGIC

  def years_on_planit
    (Time.now().to_f - created_at.to_f) / (60*60*24*365.25)
  end

  private

  def notify_signup()
    if pending?
      OneTimeTask.execute( { action: "WaitlistUser", target: self } ) do
        UserMailer.welcome_waitlist(self).deliver_now
        AdminMailer.notify_of_signup(self).deliver_now
      end
    elsif member?
      OneTimeTask.execute( { action: "InviteUser", target: self } ) do
        UserMailer.welcome_invited(self).deliver_now
        AdminMailer.notify_of_signup(self).deliver_now
      end
    end
  end
  
end