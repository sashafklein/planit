class PageFeedbacksController < ApplicationController

  before_action :authenticate_user!

  def create
    nps = current_user.nps_feedbacks.create(nps_feedback_params)
    page = current_user.page_feedbacks.new(details: PageFeedback.details(page_feedback_params), url: request.env['HTTP_REFERER'], nps_feedback_id: nps.id)

    if page.save
      AdminMailer.new_feedback(page.id).deliver_later
      redirect_back(key: :success, msg: "Thanks for the feedback!")
    else
      AdminMailer.failed_feedback(nps, current_user, request.env["HTTP_REFERER"]).deliver_later
      redirect_back(key: :error, msg: "Uh oh! Something went wrong. We've been notified.")
    end
  end

  private

  def page_feedback_params
    feedback_params.except(:nps_feedback)
  end

  def feedback_params
    params.require(:page_feedback).permit(:suggestion, :imitation, :description, :awesome, :basic, nps_feedback: [:rating])
  end

  def nps_feedback_params
    feedback_params.slice(:nps_feedback)[:nps_feedback]
  end
end