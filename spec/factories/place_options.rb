FactoryGirl.define do
  factory :place_option do
    sequence(:names) { |n| ["Place Name #{n}", "Local Name #{n}"] }
    postal_code '94114'
    sequence(:street_addresses) { |n| ["#{n} Some Street"] }
    phones ["1234167890"]
    country "SomeCountry"
    region "StateName"
    locality "CityName"
    lat 1.5
    lon 1.5
    website "www.whatever.com"
    categories ["Some category"]
    foursquare_id 'abcde12345'
    timezone_string 'America/Whatever'
  end
end