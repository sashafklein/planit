FactoryGirl.define do
  factory :image do
    imageable { create(:place) }
    url "https://irs0.4sqi.net/img/general/622x440/21990465_T5wRK5Ma00xFnkx4EgLsbOjU2ImUMb30Y0xvH7_7VRQ.jpg"
    source "Foursquare"
  end
end
