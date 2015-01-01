namespace :cities  do
  task all: :environment do
    file_path = File.join(Rails.root, 'lib', 'cities', "#{key}.yml")
    return if File.exist? file_path
    all_cities = File.read File.join(Rails.root, 'tmp', 'all_cities.txt')
    all_cities_hash = all_cities_to_hash(all_cities)
    
    puts "Done adding cities to hash!"

    all_cities_hash.each do |key, value|
      puts "Writing file #{key}.yml"
      output = File.open( File.join(Rails.root, 'lib', 'cities', "#{key}.yml"), "w" )
      yaml = value.to_yaml
      output << yaml
      output.close
    end
    puts "Compelte?"
  end

  task priority: :environment do
    file_path = File.join(Rails.root, 'lib', 'cities', "top.yml")
    raise("That file already exists. Not overwriting") if File.exists? file_path
    
    top_cities = File.read File.join(Rails.root, 'tmp', 'top_cities.txt')
    top_cities_to_hash = top_cities_to_hash(top_cities)
    output = File.open( file_path, "w" )
    yaml = top_cities_to_hash.to_yaml
    output << yaml
    output.close
  end

  private



  def top_cities_to_hash(cities)
    hash = {}
    city_lines = cities.split("\n")
    city_lines.each do |line|
      next if line.nil?
      array = line.split(",")
      next unless array[0] && array[1]
      accented = array[0]
      no_accent = I18n.transliterate accented

      hash[no_accent.downcase] = { no_accent: no_accent, accented: accented, country: array[1] }
    end
    return hash

  rescue 
    raise
  end


  def all_cities_to_hash(all_cities)
    all_cities_hash = {}
    all_cities_lines = all_cities.split("\n")
    all_cities_lines.in_groups_of(1000).each do |city_line_group|
      city_line_group.each do |city_line|
        next if city_line.nil?
        @split_city_line = city_line.split(',')
        next if @split_city_line.nil? || @split_city_line[0].blank? || @split_city_line[1].blank? || @split_city_line[2].blank?
        if all_cities_hash[country_code(@split_city_line)].nil?
          all_cities_hash[country_code(@split_city_line)] = {}
        end
        puts "Adding #{unaccented_name(@split_city_line)}, #{country_code(@split_city_line)}"
        all_cities_hash[country_code(@split_city_line)][unaccented_name(@split_city_line)] = { accented: accented_name(@split_city_line), region: region(@split_city_line) }
      end
    end
    all_cities_hash  

  rescue 
    binding.pry
    raise
  end

  def priority_cities_to_hash(priority_cities)
    
  end

  def country_code(city_line)
    city_line[0]
  end

  def unaccented_name(city_line)
    city_line[1]
  end

  def accented_name(city_line)
    city_line[2]
  end

  def region(city_line)
    city_line[3]
  end


end