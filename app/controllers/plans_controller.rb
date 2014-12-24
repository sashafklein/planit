class PlansController < ApplicationController
  
  before_action :load_plan, only: [:show, :print, :edit]
  before_action :authenticate_user!, only: [:new, :edit]

  def show
  end

  def print
  end

  def new
  end

  def edit
  end

  private

  def load_plan
    @plan = Plan.includes(:moneyshots, legs: [{ days: [{ items: [{mark: :place}] }] }] )
                .friendly.find(params[:id])
  end

end