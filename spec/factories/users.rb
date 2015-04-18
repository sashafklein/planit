# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do

    transient do 
      name "First Last"
    end

    sequence(:email) { |n| "whatever#{n}-#{rand(100)}@email.com" }
    password 'password'
    first_name { name.split(" ").first }
    last_name  { name.split(" ").last  }
    role :member
  end
end
