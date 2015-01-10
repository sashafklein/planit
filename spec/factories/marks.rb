# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mark do
    lodging false
    meal false
    notes "Some notes on something"
    show_tab false
  end

  trait :with_place do
    place
  end

  factory :mark_with_place, traits: [:with_place]
end