class Api::V1::MarksController < ApiController

  def destroy
    @mark = Mark.find(params[:id])
    return permission_denied_error unless @mark.user == current_user
    @mark.destroy
    success
  end
end