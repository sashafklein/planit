module TaskRunners
  class FromTestYml

    def seed(filename=nil)
      return load_and_save_yml_file(filename) if filename

      entries( yml_base_path ).each do |folder|
        entries( yml_base_path, folder ).each do |file|  
          load_and_save_yml_file(yml_base_path, folder, file)
        end  
      end  
    end

    private

    def load_and_save_yml_file(yml_base_path, folder, entry)
      return unless is_yml?(entry)

      yml = load_file( yml_base_path, folder, entry )

      yml.select(&:place).each do |place_hash|
        begin
          complete_place(place_hash)
        rescue
          next
        end
      end
    end

    def complete_place(place_hash)
      name = name_from_place_hash(place_hash)
      puts "Sleeping to avoid Google API request/second limit"
      sleep 0.5 # To avoid Google Api request/second limit
      save(place_hash)
    end

    def save(place_hash)
      puts "Saving #{name}"
      completed = Completers::Completer.new(place_hash, niko).complete!
      puts "Saved #{name} -- hit #{completed.completion_steps.join(", ")}"
    end

    def yml_base_path
      File.join(Rails.root, 'spec', 'support', 'pages')
    end

    def is_yml?(file)
      file[-3..-1] == 'yml'
    end

    def load_file(*path_segments)
      YAML.load_file( File.join(path_segments) ).map(&:to_sh)
    end

    def entries(*path_segments)
      Dir.open( File.join(path_segments) ).entries.reject{ |e| e == '.' || e == '..' }
    end

    def niko
      @niko ||= User.friendly.find('niko-klein')
    end

    def names_from_place_hash(ph)
      ph.place.name || ( ph.place.names.try(:first) || 'unnamed' )
    end
  end
end