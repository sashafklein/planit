class SharesController < ApplicationController
  
  before_action :authenticate_member!, only: [:create]

end