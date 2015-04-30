class PlansController < ApplicationController
  
  before_action :load_plan, only: [:new, :show, :edit, :print, :copy]
  before_action :authenticate_user!, only: [:new, :edit, :print, :copy]
  before_action :authenticate_member!, only: [:new, :edit, :print, :copy]

  def show
    if current_user_owns?(@plan)
      redirect_to "/?plan=#{@plan.id}"
    elsif current_user_is_active && !current_user_owns?(@plan)
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

    if !current_user_is_active && @plan.present?
      redirect_to plan_path( @plan.id )
    elsif !current_user_is_active && !@plan.present?
      redirect_to beta_path
    elsif params[:plan].present? && !@plan.present?
      flash[:error] = "Woops, no plan there... ;-(..."
      redirect_to root_path
    end
  end

  private

  def load_plan
    @plan = Plan.includes(legs: [{ days: [{ items: [{mark: :place}] }] }] )
                .find( params[:id] )
  end

end