require 'spec_helper'

describe YamlToModel do
  describe '#to_model!' do
    it "transfers all plan, leg, day, item, and travel information correctly" do
      new_plan = YamlToModel.new(yaml).to_model!
      leg = new_plan.legs.first

      expect(new_plan.legs.count).to eq 1
      expect(leg.days.count).to eq 2

      expect(leg.days.first.items.first.arrival).to be
      expect(leg.days.first.items.first.departure).not_to be

      expect(leg.days.last.items.last.arrival).not_to be
      expect(leg.days.last.items.last.departure).to be

      first_day = leg.days.first
      item_names = first_day.items.includes(:location).map(&:name)
      expect(item_names).to eq(["Narita airport", "Narita express", "Shinjuku station", 'fuunji ramen', 'park hyatt bar', 'hilton tokyo shinjuku'])

      expect(first_day.items.first.location.lat).to be_within(0.00001).of 35.76892253276146
    end
  end
end

# Abridged Klein Japan trip - one leg, with just first and last day
def yaml
  return @file if @file
  path = "#{Rails.root}/app/models/plans/yaml/"
  file = YAML.load_file(path + 'klein-japan.yml')

  file['legs'][1..-1].each{ |leg| file['legs'].delete(leg) }
  
  first_leg = file['legs'][0]
  first_leg['days'][1..-2].each { |day| first_leg['days'].delete(day) }

  @file = file
end