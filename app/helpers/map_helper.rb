module MapHelper

  # GENERATE TO-SPLIT STRING FOR ANGULAR
  def to_map_string(active_array)
    active_array.coordinates
    active_array.all_names
    active_array.all_ids
    active_array.all_types
    # coordinates: @user.marks.coordinates, names: @user.marks.all_names.join('/+/'), ids: @user.marks.all_ids.join('+'), path: place_path(@user.marks.first),
  end
  
end