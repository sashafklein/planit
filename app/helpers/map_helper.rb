module MapHelper

  # GENERATE TO-SPLIT STRING FOR ANGULAR
  def to_map_string(active_array)
    active_array.coordinates
    active_array.allnames
    active_array.allids
    active_array.alltypes
    # coordinates: @user.marks.coordinates, names: @user.marks.allnames.join('/+/'), ids: @user.marks.allids.join('+'), path: place_path(@user.marks.first),
  end
  
end