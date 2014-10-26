siteName = "Jet Setter"
ratingsBase = "100"

nameOptionArray = [
  ["h1[itemprop='name']", (selector) ->
    bySelector(selector)
  ]
]
name = chooseOption(nameOptionArray)

fullAddressOptionArray = [
  ["h4.location", (selector) ->
    bySelector(selector)
  ]
]
fullAddressElement = chooseOption(fullAddressOptionArray)
if fullAddressElement && fullAddressElement.length
  fullAddress = trim( deTag( fullAddressElement ) )

imageListElement = []
imageList = []
imagesOptionArray = [
  ["div#screen-gallery", (selector) ->
    for image in $(selector).find("img")
      imageListElement.push( { url: $(image).attr("src"), source: document.URL, credit: siteName } )
    return imageListElement
  ]
]
imageList = chooseOption(imagesOptionArray)
if imageList && imageList.length
  photoToUse = imageList[0].url
  
priceInfoOptionArray = [
  ["div.pricing-display", (selector) ->
    bySelector(selector)
  ]
]
priceInfoElement = chooseOption(priceInfoOptionArray)
if priceInfoElement && priceInfoElement.length
  priceInfo = priceInfoElement.split('<div class="button book">')[0]

category = "hotel"

ratingOptionArray = [
  ["div[itemprop='aggregateRating']", (selector) ->
    bySelector(selector)
  ]
]
if chooseOption(ratingOptionArray) && chooseOption(ratingOptionArray).length
  rating = trim( deTag( chooseOption(ratingOptionArray) ) )
  
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