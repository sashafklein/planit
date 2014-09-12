# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :plan do
    title "MyString"
    user_id 1
    description "MyText"
    duration 1
    notes "MyText"
    permission "MyString"
    rating 1.5
    starts_at "2014-09-12 01:01:19"
    ends_at "2014-09-12 01:01:19"
  end
end
