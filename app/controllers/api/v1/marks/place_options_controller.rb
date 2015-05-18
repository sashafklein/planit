class Api::V1::Marks::PlaceOptionsController < ApiController

  before_action :load_mark

  def index
    permission_denied_error unless current_user && current_user.owns?(@mark)

    render json: @mark.place_options, each_serializer: PlaceOptionsSerializer
  end

  private

  def load_mark
    @mark = Mark.find params[:mark_id]
  end

end