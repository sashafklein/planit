#start clean
name = ""
streetAddress = ""
locality = ""
region = ""
country = ""
postalCode = ""
country = ""
phone = ""
website = ""
category = []
priceInfo = ""
sourceNotes = ""
ranking = ""
rating = ""
imageList = []
photoToUse = "blank.gif"
siteName = ""
lat = ""
lon = ""

# meat of it

siteName = "Yelp"
ratingsBase = "5"

nameOptionArray = [
  ['h1.biz-page-title', (selector) ->
    trim(bySelector(selector))
  ]
]
name = chooseOption(nameOptionArray)

addressOptionArray = [
  ["span[itemprop='streetAddress']", (selector) ->
    bySelector(selector)
  ]
]
streetAddress = chooseOption(addressOptionArray)

localityOptionArray = [
  ["span[itemprop='addressLocality']", (selector) ->
    bySelector(selector)
  ]
]
locality = chooseOption(localityOptionArray)

regionOptionArray = [
  ["span[itemprop='addressRegion']", (selector) ->
    bySelector(selector)
  ]
]
region = chooseOption(regionOptionArray)

postalCodeOptionArray = [
  ["span[itemprop='postalCode']", (selector) ->
    bySelector(selector)
  ]
]
postalCode = chooseOption(postalCodeOptionArray)

phoneOptionArray = [
  ["span.biz-phone", (selector) ->
    trim(bySelector(selector))
  ]
]
phone = chooseOption(phoneOptionArray)

latLonOptionArray = [
  ["div.mapbox-map:visible", (selector) ->
    if $(selector) && $(selector).length
      latLonElement = $(selector).find("img").attr("src").split("center=")[1].split("&")[0]
      latLonElement.replace("%2C", ',')    
  ]
]
if chooseOption(latLonOptionArray) && chooseOption(latLonOptionArray).length
  lat = chooseOption(latLonOptionArray).split(",")[0]
  lon = chooseOption(latLonOptionArray).split(",")[1]

imageOptionArray = [
  ["img.photo-box-img:visible", (selector) ->
    $(selector).attr("src")
    # NEEDSFOLLOWUP
    # cycle through all images with class?
  ]
]
imageList.push( { url: chooseOption(imageOptionArray), source: document.URL, credit: siteName } )
image = chooseOption(imageOptionArray)

priceInfoOptionArray = [
  ["span[itemprop='priceRange']", (selector) ->
    trim(bySelector(selector))
  ]
]
priceInfo = chooseOption(priceInfoOptionArray)

ratingInfoOptionArray = [
  ["i.star-img", (selector) ->
    $(selector).attr('title').split(" star")[0]
  ]
]
rating = chooseOption(ratingInfoOptionArray)

categoryInfoOptionArray = [
  ["span.category-str-list", (selector) ->
    trim(deTag(bySelector(selector)))
  ]
]
if chooseOption(categoryInfoOptionArray) && chooseOption(categoryInfoOptionArray).length
  category = chooseOption(categoryInfoOptionArray).split(', ')

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