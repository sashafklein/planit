class SharesController < ApplicationController
  
  before_action :authenticate_member!, only: [:create]

  def create
    return redirect_back(key: :error, msg: "Woops!  Looks like an invalid email!") unless emails.any?

    emails.each do |email|
      sharee = User.where(email: email).first_or_initialize
      unless Share.save_and_send(sharee: sharee, sharer: current_user, url: url, notes: share_params[:notes], obj: object )
        return redirect_back(key: :error, msg: "Uh oh! Something went wrong. We've been notified.")
      end
    end

    redirect_back(key: :success, msg: "Thanks for sharing the Love!")
  end

  private

  def share_params
    params.require(:share).permit(:email, :notes, :obj_id, :obj_type)
  end

  def is_email?( string )
    string.scan(Devise.email_regexp).flatten.first
  end

  def object
    if params[:share][:obj_id].present? && params[:share][:obj_type].present?
      obj_class = params[:share][:obj_type].to_s.singularize.camelize.constantize
      obj_class.find_by( id: params[:share][:obj_id] )
    end
  end

  def url
    request.env["HTTP_REFERER"]
  end

  def arrayify(email_string)
    email_string.to_s.split(",").join(" ").split(" ").flatten.reject(&:blank?).map(&:strip)
  end

  def emails
    @email ||= arrayify(share_params[:email]).select{ |em| is_email?(em) }
  end
end