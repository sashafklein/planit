FactoryGirl.define do
  factory :note do
    body "Yo bitch that was insane" 
    obj { create(:mark) }
    source { create(:user) }
  end
end
