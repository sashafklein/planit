
class YamlToModel

  def self.dir_to_model!
    path = "#{Rails.root}/app/models/plans/yaml/"
    Dir.foreach(path) do |file|
      next if file == '.' or file == '..'
      puts "Serializing #{file}..."
      
      @yaml = YAML.load_file( "#{path}#{file}" )
      YamlToModel.new(@yaml).to_model!
    end
  end

  def initialize(yaml)
    @number = 1
    @yaml = yaml
  end

  def to_model!
    user_from_yaml!
    plan_from_yaml!
    legs_from_yaml!
  end

  def user_from_yaml!
    @user = User.where(first_name: @yaml[:author].split[0], last_name: @yaml[:author].split[1]).first_or_create!(email: "fake#{@number}@email.com", password: 'password')
    @number += 1
    puts "User created or fetched: #{@user.name}"
  end

  def plan_from_yaml!
    @plan = Plan.create!(
      title: @yaml[:title],
      user: @user,
      starts_at: DateTime.parse(@yaml[:start_date]),
      description: @yaml[:summary_text]
    )
  end

  def legs_from_yaml!
    @yaml[:legs].compact.each_with_index do |leg, index|
      @leg = @plan.legs.create!(
        name: leg['name'],
        order: index,
        notes: leg[:notes]
      )
      puts "Created leg: #{@leg.name} - #{@leg.id}"
      days_from_yaml!(leg)
    end
  end

  def days_from_yaml!(leg)
    leg[:days].compact.each_with_index do |day, index|
      @day = leg.days.create!(order: index, notes: day[:notes])
      puts "Created day for leg #{@leg.id}: #{@day.id}"
      items_from_yaml!(day)
    end
  end

  def items_from_yaml!(day)
    day[:items].compact.each_with_index do |item, index|
      @location = Location.create!(
        name: item[:name],
        local_name: item[:local_name],
        genre: item[:category],
        city: item[:city],
        state: item[:state],
        lat: item[:lat],
        lon: item[:lon],
        phone: item[:phone],
        street_address: item[:street_address],
        url: item[:website]
      )
      puts "Created location: #{@location.name}"
      @item = day.items.create!(
        leg_id: @leg.id,
        day_id: @day.id,
        mark: item[:planit_mark],
        category: item[:category],
        notes: item[:notes],
        show_tab: item[:has_tab],
        lodging: item[:lodging],
        meal: item[:meal],
        location_id: @location.id,
        source: item[:source],
        source_url: item[:source_url]
      )
      puts "Created item: #{@item.id} - #{@item.location.name}"
    end
  end
end