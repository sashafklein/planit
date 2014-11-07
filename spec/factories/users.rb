# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "whatever#{n}@email.com" }
    password 'password'
  end
end
