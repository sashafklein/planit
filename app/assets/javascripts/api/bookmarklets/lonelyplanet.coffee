
# NEEDSFOLLOWUP
imageList = []
if $("div.slider__container") && $("div.slider__container").length
  for image in $("div.slider__container").find("img")
    imageList.push( { url: $(image).attr("src"), source: document.URL, credit: siteName } )
  image = imageList[0].url
  
ratingInfoOptionArray = [
  ["div.card--top-choice:visible", (selector) ->
    if $(selector) then "Lonely Planet Top Choice"
  ]
]
rating = chooseOption(ratingInfoOptionArray)

priceInfoOptionArray = [
  ["dt:contains('Prices')", (selector) ->
    $(selector).next().html()
  ]
]
priceInfo = chooseOption(priceInfoOptionArray)

return {
  name: name
  street_address: streetAddress
  locality: locality
  region: region
  postalCode: postalCode
  country: country
  phone: phone
  website: website
  category: category
  priceInfo: priceInfo
  sourceNotes: sourceNotes
  rating: rating
  ranking: ranking
  images: imageList
  tab_image: photoToUse
  image_credit: siteName
  source: siteName
  source_url: document.URL
  lat: lat
  lon: lon
  has_tab: true
  parent_day: null
}