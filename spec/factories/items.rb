FactoryGirl.define do
  factory :item do
    plan

    transient do 
      place_options({})
    end

    mark { create(:mark, place_options: place_options) }
  end
end
