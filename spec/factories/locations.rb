# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :location do
    name "MyString"
    local_name "MyString"
    postal_code "MyString"
    street_address "MyString"
    phone "MyString"
    state "MyString"
    city "MyString"
    lat 1.5
    lon 1.5
    url "MyString"
    genre "MyString"
    subgenre "MyString"
  end
end
