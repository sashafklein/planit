siteName = "Conde Nast Traveler"
ratingsBase = "100"

nameOptionArray = [
  ["h1.title", (selector) ->
    bySelector(selector)
  ] 
]
name = chooseOption(nameOptionArray)

fullAddressOptionArray = [
  ["span.adr", (selector) ->
    bySelector(selector)
  ]
]
fullAddressElement = chooseOption(fullAddressOptionArray)
if fullAddressElement && fullAddressElement.length
  fullAddress = trim( deTag( fullAddressElement ) )

addressOptionArray = [
  ["span.street-address", (selector) ->
    bySelector(selector)
  ]
]
streetAddress = chooseOption(addressOptionArray)

localityOptionArray = [
  ["span.locality", (selector) ->
    bySelector(selector)
  ]
]
locality = chooseOption(localityOptionArray)

countryOptionArray = [
  ["span.country-name", (selector) ->
    bySelector(selector)
  ]
]
country = chooseOption(countryOptionArray)

postalCodeOptionArray = [
  ["span.postal-code", (selector) ->
    bySelector(selector)
  ]
]
postalCode = chooseOption(postalCodeOptionArray)

imageListElement = []
imageList = []
imagesOptionArray = [
  ["div.gallery", (selector) ->
    for image in $(selector).find("img")
      imageListElement.push( { url: $(image).attr("src"), source: document.URL, credit: siteName } )
    return imageListElement
  ]
]
imageList = chooseOption(imagesOptionArray)
if imageList && imageList.length
  photoToUse = imageList[0].url
  
categoryOptionArray = [
  ["h5.type", (selector) ->
    bySelector(selector)
  ]
]
category = chooseOption(categoryOptionArray)

priceInfoOptionArray = [
  ["div.price-rating", (selector) ->
    bySelector(selector)
  ]
]
priceInfo = chooseOption(priceInfoOptionArray)

ratingOptionArray = [
  ["div.venue-results", (selector) ->
    $(selector).find("li.score").html()
  ]
]
rating = chooseOption(ratingOptionArray)

return {
  name: name
  fullAddress: fullAddress
  streetAddress: streetAddress
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