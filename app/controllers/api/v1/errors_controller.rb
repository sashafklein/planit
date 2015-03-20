class Api::V1::ErrorsController < ApiController

  def create
    details = params[:error].merge({ time: DateTime.now.strftime, current_user_id: current_user.try(:id) })
    AdminMailer.report_error(details).deliver_later
    success
  end

end