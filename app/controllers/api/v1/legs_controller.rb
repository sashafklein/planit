class Api::V1::LegsController < ApiController
  
  before_action :load_leg, only: [:map]

  def map
    
  end

  private

  def load_leg
    @leg = Leg.find(params[:id])
  end
end