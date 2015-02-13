# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mark do
    user
    place
    lodging false
    meal false
    notes "Some notes on something"
    show_tab false
  end

  factory :mark_with_place, traits: [:with_place]
end