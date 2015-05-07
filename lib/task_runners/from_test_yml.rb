module TaskRunners
  class FromTestYml

    def self.destroy_all
      [Place, Mark, Item, Plan, Image, Flag].map(&:destroy_all)
    end
    
    def seed(folder='', filename=nil, name=nil)
      @current = 0
      File.open(log_file, 'w') { |file| Date.today.strftime("Seeded %b %d, %Y")   }
      return load_and_save_yml_file(yml_base_path, folder, filename, name) if filename

      entries( yml_base_path ).each do |folder|
        entries( yml_base_path, folder ).each do |file|  
          load_and_save_yml_file(yml_base_path, folder, file)
        end  
      end  
    end

    private

    def load_and_save_yml_file(yml_base_path, folder, entry, name=nil)
      return unless is_yml?(entry)

      @original_logger_level = ActiveRecord::Base.logger.level
      ActiveRecord::Base.logger.level = 1

      yml = load_file( path = path(yml_base_path, folder, entry) ).select(&:place)
      yml = yml.is_a?(Hash) ? yml.to_sh : yml.map(&:to_sh)
      yml = yml.select{ |e| e.place.name == name || e.place.names.try(:include?, name) } if name

      yml.each do |place_hash|
        place_hash.place.filepath = path
        begin
          complete_place(place_hash)
        rescue => e
          print "ERROR: #{e}", :red
          print( '---' + e.backtrace.first(10).join("\n---"), :red )
          next
        end
      end
    ensure
      ActiveRecord::Base.logger.level = @original_logger_level
    end

    def complete_place(place_hash)
      sleep 0.7 # To avoid Google Api request/second limit
      save(place_hash, name_from_place_hash(place_hash))
    end

    def save(place_hash, name)
      print "#{@current += 1}: Saving #{name} -- Path: #{place_hash[:place][:filepath]}"
      completed = Completers::Completer.new(place_hash, niko, place_hash[:scraper_url]).complete!
      if completed
        if completed.place
          print "Saved #{name} as Place ##{completed.place.id} -- hit #{completed.place.completion_steps.join(", ")}"
        else # place options
          print "Saved Place Options for #{name} -- ids #{completed.place_options.pluck(:id)}"
        end
      else
        print "FAILURE: Failed to save #{name}. Incoming data: #{place_hash.to_s}", :red
      end
      print '--------------------------------------', :white
    end

    def yml_base_path
      File.join(Rails.root, 'spec', 'support', 'pages')
    end

    def is_yml?(file)
      file[-3..-1] == 'yml'
    end

    def path(*path_segments)
      File.join(path_segments)
    end

    def load_file(path)
      YAML.load_file( path ).map(&:to_sh)
    end

    def entries(*path_segments)
      Dir.open( File.join(path_segments) ).entries.reject{ |e| e == '.' || e == '..' }
    end

    def niko
      @niko ||= User.friendly.find('niko-klein')
    end

    def name_from_place_hash(ph)
      ph.place.name || ( ph.place.names.try(:first) || 'unnamed' )
    end

    def log_file
      @file ||= File.join( Rails.root, 'lib', 'task_runners', 'log', 'from_test_yml.txt')
    end

    def print(text, color=:green)
      File.open(log_file, 'a') { |file| file.puts(text) }
      puts text.colorize( color ) 
    end
  end
end