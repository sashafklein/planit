FactoryGirl.define do
  factory :leg do
    sequence(:name) { |n| "Plan name #{n}"}
  end
end
