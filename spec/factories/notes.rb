FactoryGirl.define do
  factory :note do
    body( "Yo bitch that was insane" )
    object{ create(:mark) }
    source{ create(:user) }
  end
end
