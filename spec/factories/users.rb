# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "whatever#{n}-#{rand(100)}@email.com" }
    password 'password'
    first_name "First"
    last_name "Last"
    role :member
  end
end
