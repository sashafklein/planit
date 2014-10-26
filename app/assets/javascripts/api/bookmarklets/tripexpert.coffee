siteName = "TripExpert"
ratingsBase = "100"

nameOptionArray = [
  ["h1[itemprop='name']", (selector) ->
    trim(bySelector(selector))
  ]
]
name = chooseOption(nameOptionArray)

priceInfoOptionArray = [
  ["span:contains('from $')", (selector) ->
    bySelector(selector).split('from ')[1]
  ]
]
priceInfo = chooseOption(priceInfoOptionArray)

category.push 'hotel'

ratingOptionArray = [
  ["span.score", (selector) ->
    bySelector(selector)
  ]
]
rating = chooseOption(ratingOptionArray)

rankingOptionArray = [
  ["p:contains('say expert reviewers')", (selector) ->
    $(selector).next().html()
  ]
]
if chooseOption(rankingOptionArray) && chooseOption(rankingOptionArray).length
  ranking = chooseOption(rankingOptionArray).split("#")[1].split(" in")[0]

countryOptionArray = [
  ["ul.breadcrumb", (selector) ->
    $(selector).find("a").html()
  ]
]
country = chooseOption(countryOptionArray)

localityOptionArray = [
  ["ul.breadcrumb", (selector) ->
    deTag($(selector).find("li").next().html())
  ]
]
locality = chooseOption(localityOptionArray)

fullAddressOptionArray = [
  ["p.address", (selector) ->
    deBreak(deTag(bySelector(selector)))
  ]
]
if chooseOption(fullAddressOptionArray) && chooseOption(fullAddressOptionArray).length
  fullAddress = chooseOption(fullAddressOptionArray)
  streetAddress = fullAddress.split(", #{locality}, ")[0]
  region = fullAddress.split(", #{country}")[0].split(", #{locality}, ")[1]

imageContainerArray = ["ul.slides"]
getImages(imageContainerArray)
if imageList && imageList.length
  photoToUse = imageList[0].url

return {
  name: name
  streetAddress: streetAddress
  fullAddress: fullAddress
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