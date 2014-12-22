class PlansController < ApplicationController
  
  before_action :load_plan, only: [:show, :print]

  def show
  end

  def print
  end

  private

  def load_plan
    @plan = Plan.includes(:moneyshots, legs: [{ days: [{ items: [{mark: :place}] }] }] )
                .friendly.find(params[:id])
  end

end