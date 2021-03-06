class User < BaseModel

  # validates :first_name, :last_name, presence: true

  after_save :create_mail_list_email!
  before_create { self.role = :member if self.pending? }

  enum role: { pending: 0, member: 1, admin: 2 }

  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :collaborations, foreign_key: :collaborator_id
  has_many :collaborating_plans, through: :collaborations, source: :plan
  has_many :plans
  has_many :marks
  has_many :flags, as: :obj
  has_many :nps_feedbacks
  has_many :page_feedbacks
  has_many :items, through: :marks
  has_many :shares, foreign_key: :sharer_id
  has_many :received_shares, foreign_key: :sharee_id, class_name: "Share"

  has_many_polymorphic table: :one_time_tasks, name: :agent
  has_many_polymorphic table: :notes, name: :source

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  def is?(user)
    id == user.id
  end

  def owns?(record)
    record['user_id'] == id || 
      ( record['obj_id'] && record['obj_id'] == id && record['obj_type'] == 'User' ) ||
      ( record['class'] == 'Item' )
  end

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

  # LOCATIONS

  def locations
    low_level_location_ids = ObjectLocation.where( obj_id: marks_with_places.places.pluck(:id), obj_type: 'Place' ).pluck( :location_id ).uniq
    top_level_location_geonameids = Location.where( id: low_level_location_ids ).pluck( :country_id, :admin_id_1, :admin_id_2 ).flatten.uniq.compact
    location_level_query = Location.where( id: low_level_location_ids ).where( geoname_id: top_level_location_geonameids )
    Location.where(location_level_query.where_values.map(&:to_sql).join(" OR ")).uniq
  end

  # INBOX MESSAGES

  def saves_to_review
    marks.where( place_id: nil ).includes(:place_options, :sources)
  end

  def shares_to_review
    Mark.where( id: Share.where( sharee: self, obj_type: 'Mark' ).pluck(:obj_id) )
  end

  def message_count
    saves_to_review.count + shares_to_review.count
  end

  def invite!(inviter=nil)
    OneTimeTask.run(agent: inviter, detail: "Invite Sent", extras: { email: email }) do
      AcceptedEmail.where(email: email).first_or_create!
      UserMailer.welcome_invited( atts(:email, :first_name, :last_name), inviter.try(:casual_name) ).deliver_later
    end
  end


  def auto_signin_token
    g_token(attrs: [:email, :id], other: "#{Env.auto_signin_token_salt}#{encrypted_password.try(:first, 5)}")
  end

  # USER ACTIVITY

  def years_on_planit
    (Time.now().to_f - created_at.to_f) / (60*60*24*365.25)
  end

  # PRIVATE

  private

  def slug_candidates
    [:name, [:name, g_token(attrs: [:id, :name], other: Time.now.to_s).first(8)] ]
  end

  def create_mail_list_email!
    MailListEmail.where(email: email).first_or_create!(first_name: first_name, last_name: last_name)
  end
end