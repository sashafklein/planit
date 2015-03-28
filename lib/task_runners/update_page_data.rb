module TaskRunners
  class UpdatePageData

    include TaskRunners

    attr_reader :files, :list, :old, :errors, :tenuous
    def initialize
      @files = []
      @old = []
      @errors = []
      @tenuous = []
      @new_yamls = []
      @list = get_list
    end

    def get_list
      return @list if @list
      @list = []
      base = File.join *%W( #{Rails.root} spec support pages )
      entries( base ).each do |folder|
        entries( base, folder ).reject{ |e| %w( yml kml ).include? e[-3..-1]  }. each do |file|
          @files << ( full_path = File.join( base, folder, file) )
          yml = full_path.gsub(".html", '.yml')
          if File.exists?(yml)
            array = YAML.load_file(yml).to_super
            site = array.first.scraper_url || array.first.place.try(:scraper_url) || array.try(:scraper_url)
          else
            @new_yamls << yml
          end
          @list << { file: full_path, site: site || ''}
        end
      end
      @list = @list.to_super
    end

    def get_new!
      updated = []

      @new_yamls.select{ |y| !y.include?('email') }.each do |yml|
        puts "Creating file: #{yml}"
        File.open( yml, 'w' ) { |f| f.write [{ place: { scraper_url: nil } }].to_super.to_yaml }
      end

      list.select{ |e| e.site.present? }.each do |el|
        updated << el.file
        @old << (old_file = "#{el.file}.old")
        
        `mv #{el.file} #{old_file}`
        puts "Grabbing #{el.file}"
        `curl '#{el.site}' -o #{el.file}`

        if !File.exists?(el.file)
          @errors << "Didn't get anything for #{el.file}. Reversing changes."
          @old.delete(old_file)
          `mv #{old_file} #{el.file}`
        end
      end

      move_tenuous!

      puts "Updated #{updated.length} files:".colorize(:green)

      updated.each do |f|
        puts " - #{f}".colorize(:green)
      end

      failed = list.select{ |e| e.site.blank? && !e.file.include?('email') }.map(&:file)

      puts "Found no URL for #{failed.length} files:".colorize(:red)

      failed.each do |f|
        puts " - #{f}".colorize(:red)
      end

      puts "Some new pages don't seem long enough, and were sidelined:".colorize(:blue)
      
      tenuous.each do |f|
        puts " - #{f}".colorize(:blue)
      end

      errors.each{ |e| puts "#{e}".colorize(:white)}

      nil
    end

    def reinstate_old!
      old.each do |f|
        normal = f.gsub('.old', '')
        `mv #{f} #{normal}`
        puts "Overwrote #{normal} with #{f}"
      end
    end

    def delete_old!
      old.each do |f|
        `rm #{f}`
        puts "Removed Old: #{f}"
      end
    end

    def delete_tenuous!
      tenuous.each do |f|
        `rm #{f}`
        puts "Removed Tenuous: #{f}"
      end
    end

    def move_tenuous!
      list.select{ |e| e.site.present? }.each do |el|
        old_file = "#{el.file}.old"
        
        next unless File.exists?(old_file) && File.exists?(el.file)

        if (File.read(old_file).length - File.read(el.file).length) > 10000
          @tenuous << "#{el.file}.tenuous"
          @old.delete(old_file)
          `mv #{el.file} #{el.file}.tenuous`
          `mv #{old_file} #{el.file}`
        end
      end
    end
  end
end