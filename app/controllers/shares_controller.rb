class SharesController < ApplicationController
  
  before_action :authenticate_member!, only: [:create]

  def create
    if is_email?( share_params[:email] )
      sharee = User.where(email: share_params[:email]).first_or_initialize
      object = params[:share][:object_type].to_s.singularize.camelize.constantize.find( params[:share][:object_id] ) if params[:share][:object_id].present? && params[:share][:object_type].present?
      if Share.save_and_send(sharee: sharee, sharer: current_user, url: request.env["HTTP_REFERER"], notes: share_params[:notes], object: (object || nil) )
        redirect_back(key: :success, msg: "Thanks for sharing the Love!")
      else
        redirect_back(key: :error, msg: "Uh oh! Something went wrong. We've been notified.")
      end
    else
      redirect_back(key: :error, msg: "Woops!  Looks like an invalid email!")
    end
  end

  private

  def share_params
    params.require(:share).permit(:email, :notes, :object_id, :object_type)
  end

  def is_email?( string )
    string.scan(Devise.email_regexp).flatten.first
  end

end