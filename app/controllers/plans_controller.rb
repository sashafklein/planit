class PlansController < ApplicationController
  
  before_action :load_plan, only: [:new, :show, :edit, :print, :copy]
  before_action :authenticate_user!, only: [:new, :show, :edit, :print, :copy]
  before_action :authenticate_member!, only: [:new, :show, :edit, :print, :copy]

  def show
    if current_user.owns?(@plan)
      redirect_to "/?plan=#{@plan.id}"
    elsif current_user_is_active && !current_user.owns?(@plan)
      redirect_to "/?plan=#{@plan.id}" # change to view-not-edit?
    end
  end

  def print
  end

  def new
  end

  def edit
  end

  def index
    @plan = Plan.find_by( id: params[:plan] )

    if !current_user_is_active
      redirect_to beta_path
    elsif params[:plan].present? && !@plan.present?
      flash[:error] = "Woops, no plan there... ;-(..."
      redirect_to root_path
    end
  end

  def copy
    new_plan = @plan.copy!(new_user: current_user)
    flash[:success] = "'#{@plan.name}' copied successfully."
    redirect_to plan_path(new_plan.id)
  end

  private

  def load_plan
    @plan = Plan.includes(legs: [{ days: [{ items: [{mark: :place}] }] }] )
                .find( params[:id] )
  end

end