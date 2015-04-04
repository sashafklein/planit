class MorphController < ApplicationController
  
  def new
    return catch_404_error unless current_user && current_user.admin?

    morph_to = User.friendly.find(params[:id])
    session[:morphed_from]  = current_user.id
    sign_in(:user, morph_to)

    redirect_to root_path
  end

  def destroy
    if morph_from = User.friendly.find_by_id(session[:morphed_from])
      session.delete :morphed_from
      sign_in :user, morph_from
      redirect_back( key: :success, msg: "Unmorphed back to #{current_user.name} successfully.")
    else
      redirect_back( key: :error, msg: "Nobody to morph back into!")
    end
  end
end
