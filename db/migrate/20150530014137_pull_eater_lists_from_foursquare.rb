class PullEaterListsFromFoursquare < ActiveRecord::Migration
  def up
    lists_response = Apis::UserFoursquare.new(s).lists(3343327) # Eater FSID
    lists_count = lists_response.super_fetch(:response, :lists, :count)

    lists = lists_response.super_fetch(:response, :lists, :groups, 0, :items)

    3.upto(lists_count / 3) do |offset|
      new_lists_response = Apis::UserFoursquare.new(s).lists(3343327, { offset: offset } )
      binding.pry
      raise
      lists.concat new_lists_response.super_fetch(:response, :lists, :groups, 0, :items)
    end

    lists.each do |list|
      puts "Working on list: #{list.name}"
      plan = eater.plans.where(name: list.name).first_or_create

      full_list = Apis::UserFoursquare.new(s).list( list.id )
      item_ids = full_list.super_fetch(:response, :list, :listItems, :items, 0, :venue).map(&:id)
      
      item_ids.each do |id|
        venue = Apis::Foursquare.new(s).venue(id)
        data = serialize(venue)
        puts "Adding #{ data[:name] }"
        plan.add_item_from_place_data!(user_id: eater.id, plan_id: plan.id, data: data)
      end
    end
  end

  def down
    # eater.plans.destroy_all
  end

  private

  def eater
    @eater ||= User.find_by(email: 'eater@plan.it')
  end

  def s
    @s ||= User.find(13)
  end

  def serialize(venue)
    v = venue.super_fetch(:response, :venue)
    {
      name: v.name,
      names: ([v.name]).flatten.compact,
      image_url: p ? [ p['prefix'], p['suffix'] ].join("69x69") : nil,
      foursquare_icon: v.categories ? [v.categories[0].icon.prefix, v.categories[0].icon.suffix].join("bg_64") : nil,
      foursquare_id: v.id,
      categories: (v.categories || [] ).map{ |c| c['name'] },
      street_addresses: [v.location.try(:address)].flatten.compact,
      sublocality: v.location.try(:neighborhood),
      locality: v.location.try(:city),
      region: v.location.try(:state),
      country: v.location.try(:country),
      lat: v.location.try(:lat),
      lon: v.location.try(:lng)
    }
  end
end
