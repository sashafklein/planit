FactoryGirl.define do
  factory :source do
    object { create(:mark) }
    name "Planit"
    full_url "https://plan.it/places?whatever=bam"
    trimmed_url "https://plan.it/places?whatever=bam"
    base_url "https://plan.it"
    description "Best site ever!"
  end
end