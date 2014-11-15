# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :place do
    sequence(:names) { |n| ["Place Name #{n}", "Local Name #{n}"] }
    postal_code '94114'
    sequence(:street_addresses) { |n| ["#{n} Some Street"] }
    phones {{ default: "1234167890" }}
    country "SomeCountry"
    region "StateName"
    locality "CityName"
    lat 1.5
    lon 1.5
    website "www.whatever.com"
    categories ["Some category"]
  end
end
