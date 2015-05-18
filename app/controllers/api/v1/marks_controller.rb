class Api::V1::MarksController < ApiController

  before_action :load_mark, except: [:create]

  # PLACE OPTIONS

  def choose
    return permission_denied_error unless @mark && @mark.user == current_user && @mark.place_options.any?
    place_option = @mark.place_options.find(params[:place_option_id])
    place = place_option.choose!
    render json: place, serializer: SearchPlaceSerializer
  end

  # REGULAR MARKS

  def create # ie "save"
    return permission_denied_error unless current_user
    if place = Place.find(params[:place_id])
      if mark = Mark.unscoped.where( user: current_user, place_id: place.id ).first
        mark.update_attributes!(deleted: false) if mark.deleted?
      else
        current_user.marks.create!( place: place )
      end
      success
    else
      # Place Complete first or create
      error
    end
  end

  def index
    if params[:scoped]
      @marks = Mark.where( conditions )
    else
      @marks = Mark.unscoped.where( conditions )
    end
    render json: @marks, each_serializer: serializer
  end

  def show
    return permission_denied_error unless @mark && @mark.user == current_user
    render json: @mark, serializer: MarkPlaceOptionsSerializer
  end

  def love
    return permission_denied_error unless @mark && @mark.user == current_user
    @mark.update_attributes!(loved: true)
    success
  end
  
  def unlove
    return permission_denied_error unless @mark && @mark.user == current_user
    @mark.update_attributes!(loved: false)
    success
  end
  
  def been
    return permission_denied_error unless @mark && @mark.user == current_user
    @mark.update_attributes!(been: true)
    success
  end

  def notbeen
    return permission_denied_error unless @mark && @mark.user == current_user
    @mark.update_attributes!(been: false)
    success
  end

  def remove
    return permission_denied_error unless @mark && @mark.user == current_user
    @mark.update_attributes!(deleted: true)
    success
  end

  def destroy
    return permission_denied_error unless @mark && @mark.user == current_user
    @mark.destroy
    success
  end

  private

  def load_mark
    if mark_id = params[:id]
      @mark = Mark.unscoped.find( mark_id )
    elsif place_id = params[:place_id]
      @mark = Mark.unscoped.where( place_id: place_id, user: current_user ).first
    end
  end

  def conditions
    return {} unless params[:conditions]
    params[:conditions].is_a?(String) ? JSON.parse(params[:conditions]) : params[:conditions]
  end

  def serializer
    if params[:serializer]
      params[:serializer].try(:constantize)
    else
      MarkSerializer
    end
  end

end