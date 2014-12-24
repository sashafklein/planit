namespace :seed  do
  task from_test_yml: :environment do
    base = File.join(Rails.root, 'spec', 'support', 'pages')
    Dir.open(File.join(base)).entries.reject{ |e| e == '.' || e == '..' }.each do |entry|
      Dir.open(File.join(base, entry)).entries.reject{ |e| e == '.' || e == '..' }.each do |e|  
        if e[-3..-1] == 'yml'    
          file = YAML.load_file(File.join(base, entry, e)).map(&:recursive_symbolize_keys)
          niko = User.friendly.find('niko-klein')
          file.each do |place_hash|
            begin
              next unless place_hash[:place]
              name = place_hash[:place][:name] || names = place_hash[:place][:names] ? names[0] : 'unnamed'
              puts "Sleeping to avoid Google API request/second limit"
              sleep 1 # To avoid Google Api request/second limit
              puts "Saving #{name}"
              completed = Services::Completer.new(place_hash, niko).complete!
              puts "Saved #{name}"
            rescue
              next
            end
          end
        end  
      end  
    end  
  end
end