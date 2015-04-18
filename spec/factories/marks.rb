# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mark do
    user
    lodging false
    meal false
    show_tab false

    transient do
      place_options({})
    end

    place { create(:place, place_options )}
  end
end