# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :travel do
    mode "MyString"
    origin_id 1
    destination_id 1
    departs_at "2014-09-12 01:18:48"
    arrives_at "2014-09-12 01:18:48"
    vessel "MyString"
    next_step_id 1
    notes "MyText"
    carrier "MyString"
    departure_terminal "MyString"
    arrival_terminal "MyString"
    confirmation_code "MyString"
  end
end
