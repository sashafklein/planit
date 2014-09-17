class YamlToModel

  @@logger = []

  def self.dir_to_model!
    path = "#{Rails.root}/app/models/plans/yaml/"
    Dir.foreach(path) do |file|
      next if file == '.' or file == '..'

      @@logger << "Serializing #{file}..."
      
      yaml = YAML.load_file( "#{path}#{file}" )
      YamlToModel.new(yaml).to_model!
    end
  ensure
    puts @@logger.join("\n")
  end

  attr_accessor :yaml
  def initialize(yaml)
    @yaml = yaml
  end

  def to_model!
    user = user_from_yaml!
    slug_from_title = yaml['title'].split(' ').map(&:downcase).join('-')
    unless Plan.find_by_slug(slug_from_title)
      plan = plan_from_yaml!(user)
      legs_from_yaml!(plan)
    end
  end

  private
  
  def user_from_yaml!
    first, last = yaml['author'].split[0], yaml['author'].split[1]
    user = User.where(first_name: first, last_name: last).first_or_create!(email: "#{first}{last}@fake.com", password: 'password')
    @@logger << "...User created or fetched: #{user.slug}"
    user
  end

  def plan_from_yaml!(user)
    plan = Plan.create!(
      title: yaml['title'],
      user: user,
      starts_at: yaml['start_date'],
      description: yaml['summary_text']
    )
    @@logger << "...Created plan: #{plan.slug}"
    yaml['moneyshots'].each do |yaml_image|
      uploader_id = user.name == yaml_image['source'] ? user.id : nil
      image = plan.moneyshots.create!(
        url: yaml_image['url'],
        subtitle: yaml_image['subtitle'],
        uploader_id: uploader_id
      )
      @@logger << ".....Created moneyshot: #{image.id} for plan #{plan.slug}"
    end
    plan
  end

  def legs_from_yaml!(persisted_plan)
    @@logger << "...Creating legs"
    yaml['legs'].compact.each_with_index do |yaml_leg, index|
      persisted_leg = persisted_plan.legs.create!(
        name: yaml_leg['name'],
        order: index,
        notes: yaml_leg['notes']
      )
      @@logger << ".....Created leg: #{persisted_leg.name} - #{persisted_leg.id}"
      days_from_yaml!(yaml_leg, persisted_leg)
    end
  end

  def days_from_yaml!(yaml_leg, persisted_leg)
    @@logger << "...Creating days"
    yaml_leg['days'].compact.each_with_index do |yaml_day, index|
      persisted_day = persisted_leg.days.create!(order: index, notes: yaml_day['notes'])
      @@logger << ".....Created day for leg #{persisted_leg.id}: #{persisted_day.id}"
      items_from_yaml!(yaml_day, persisted_day, persisted_leg)
    end
  end

  def items_from_yaml!(yaml_day, persisted_day, persisted_leg)
    @@logger << "...Creating items"
    yaml_day['items'].compact.each_with_index do |yaml_item, index|
      persisted_location = Location.create!(
        name: yaml_item['name'],
        local_name: yaml_item['local_name'],
        genre: yaml_item['category'],
        city: yaml_item['city'],
        state: yaml_item['state'],
        lat: yaml_item['lat'],
        lon: yaml_item['lon'],
        phone: yaml_item['phone'],
        street_address: yaml_item['street_address'],
        url: yaml_item['website']
      )
      @@logger << ".....Created location: #{persisted_location.name}"
      persisted_item = persisted_day.items.create!(
        leg_id: persisted_leg.id,
        day_id: persisted_day.id,
        mark: yaml_item['planit_mark'],
        category: yaml_item['category'],
        notes: yaml_item['notes'],
        show_tab: yaml_item['has_tab'],
        lodging: yaml_item['lodging'],
        meal: yaml_item['meal'],
        location_id: persisted_location.id,
        source: yaml_item['source'],
        source_url: yaml_item['source_url']
      )
      @@logger << ".......Created item: #{persisted_item.id} - #{persisted_item.location.name}"
      image = persisted_item.images.create!(
        url: yaml_item['tab_image'],
        source: yaml_item['source']
      )
      @@logger << ".........Created image: #{image.id} - #{persisted_location.name}"
    end
  end
end