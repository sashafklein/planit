# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :place do
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

    factory :comptoir do
      names ["Le Comptoir du Relais"]
      street_addresses ["6 carrefour de l'Odeon"]
      locality "Paris"
      postal_code "75006"
      phones(["+33 1 44 27 07 97"])
      categories ["Brasseries", "French"]
      country 'France'
      hours({
        mon: [["1200","0000"]],
        tue: [["1200","0000"]],
        wed: [["1200","0000"]],
        thu: [["1200","0000"]],
        fri: [["1200","0000"]],
        sat: [["1200","0200"]],
        sun: [["1200","0000"]]
      })
      lat 48.851946
      lon 2.338757
    end
  end
end
