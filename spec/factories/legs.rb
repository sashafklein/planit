# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :leg do
    name "MyString"
    order 1
    bucket false
    notes "MyText"
    plan_id 1
  end
end
