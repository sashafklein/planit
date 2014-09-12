# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :item do
    leg_id 1
    day_id 1
    location_id 1
    lodging false
    meal false
    notes "MyText"
    arrival_id 1
    departure_id 1
    show_tab false
  end
end
