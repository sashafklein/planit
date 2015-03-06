FactoryGirl.define do
  factory :days do
    sequence(:name) { |n| "Plan name #{n}"}
  end
end
