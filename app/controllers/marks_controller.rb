class MarksController < ApplicationController

  before_action :authenticate_user!
  before_action :load_mark
  before_action :ensure_right_user!

  def show
    if @mark.place
      redirect_to @mark.place
    else
      redirect_to root_path
    end
  end

  private

  def load_mark
    @mark = Mark.find(params[:id])
  end

  def ensure_right_user!
    unless @mark.user == current_user
      flash[:error] = "That URL leads to fear. Fear leads to anger. Anger leads to hatred. And hatred... leads to the dark side."
      redirect_to root_path
    end
  end
end