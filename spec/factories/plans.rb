FactoryGirl.define do
  factory :plan do
    sequence(:name) { |n| "Plan name #{n}"}
  end
end
