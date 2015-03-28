module TaskRunners
  def entries(*path_segments)
    Dir.open( File.join(path_segments) ).entries.reject{ |e| e == '.' || e == '..' }
  end
end