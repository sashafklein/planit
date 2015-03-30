class Api::V1::MarksController < ApiController

  before_action :load_mark, only: [:destroy, :show, :choose]

  def destroy
    return permission_denied_error unless @mark.user == current_user
    @mark.destroy
    success
  end

  def show
    return permission_denied_error unless @mark.user == current_user
    render json: @mark, serializer: MarkPlaceOptionsSerializer
  end

  def choose
    return permission_denied_error unless @mark.user == current_user
    return permission_denied_error unless @mark.place_options.any?
    place_option = @mark.place_options.find(params[:place_option_id])
    place = place_option.choose!
    render json: place, serializer: SearchPlaceSerializer
  end

  private

  def load_mark
    @mark = Mark.find(params[:id])
  end

end