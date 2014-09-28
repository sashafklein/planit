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
    plan = nil
    user = user_from_yaml!
    slug_from_title = yaml['title'].split(' ').map(&:downcase).join('-')
    unless plan = Plan.find_by_slug(slug_from_title)
      plan = plan_from_yaml!(user)
      legs_from_yaml!(plan)
    end
    plan
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
      auto_hash(yaml, %w(title tips), {starts_at: 'start_date', description: 'summary_text'}).merge({
        user: user
      })
    )
    @@logger << "...Created plan: #{plan.slug}"
    yaml['moneyshots'].each do |yaml_image|
      uploader_id = user.name == yaml_image['source'] ? user.id : nil
      image = plan.moneyshots.create!(
        auto_hash(yaml_image, %w(url subtitle)).merge({ uploader_id: uploader_id })
      )
      @@logger << ".....Created moneyshot: #{image.id} for plan #{plan.slug}"
    end
    plan
  end

  def legs_from_yaml!(persisted_plan)
    @@logger << "...Creating legs"
    yaml['legs'].compact.each_with_index do |yaml_leg, index|
      persisted_leg = persisted_plan.legs.create!(
        auto_hash(yaml_leg, %w(name notes)).merge({ order: index })
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
      items_from_yaml!(yaml_day, persisted_day, persisted_leg, yaml_leg)
    end
  end

  def items_from_yaml!(yaml_day, persisted_day, persisted_leg, yaml_leg)
    @@logger << "...Creating items"

    yaml_day['items'].compact.each_with_index do |yaml_item, index|
      persisted_location = Location.where(name: yaml_item['name']).first_or_create!(
        auto_hash(
          yaml_item, 
          %w(local_name city country state lat lon phone street_address), 
          { genre: 'category', url: 'website'}
        )
      )
      @@logger << ".....Created location: #{persisted_location.name}"
      persisted_item = persisted_day.items.create!(
        auto_hash(
          yaml_item, 
          %w(category notes lodging meal source source_url), 
          { mark: 'planit_mark', show_tab: 'has_tab'}
        ).merge({
            leg_id: persisted_leg.id,
            day_id: persisted_day.id,
            location_id: persisted_location.id,
            order: index
          })
      )
      @@logger << ".......Created item: #{persisted_item.id} - #{persisted_item.location.name}"
      travel_from_yaml!(persisted_item, yaml_item)
      image = persisted_item.images.create!( 
        auto_hash(yaml_item, %w(source), {url: 'tab_image'})
      )
      @@logger << ".........Created image: #{image.id} - #{persisted_location.name}"
      
    end
  end

  def travel_from_yaml!(persisted_item, yaml_item)
    ['arrival', 'departure'].each do |travel_type|
      if yaml_item[travel_type]

        next_id = nil
        source_type = travel_type == 'arrival' ? 'to' : 'from'
        travel_items = yaml_item[travel_type].reverse

        travel_items.each_with_index do |travel_item, index|
          hash = auto_hash(travel_item, %w(departs_at arrives_at vessel departure_terminal arrival_terminal), {mode: 'method', confirmation_code: 'confirmation'}).merge({
            next_step_id: next_id
          })

          if index == 0
            travel = Travel.create!(hash.merge(source_type => persisted_item))
          else
            travel = Travel.create!(hash)
          end

          next_id = travel.id
        end
        @@logger << ".........Created travel #{source_type} #{persisted_item.location.name} -- #{travel_items.count} pieces"
      end
    end
  end

  def auto_hash(yaml_hash, attributes, rename_hash={})
    h = {}
    attributes.each do |att|
      h[att] = yaml_hash[att]
    end
    rename_hash.each do |key, yaml_key|
      h[key.to_s] = yaml_hash[yaml_key]
    end
    h
  end
end