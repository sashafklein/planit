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

siteName = "TripAdvisor"
ratingsBase = "5"

nameOptionArray = [
  ['h1#HEADING', (selector) ->
    trim(deTag(bySelector(selector)))
  ]
]
name = chooseOption(nameOptionArray)

addressOptionArray = [
  ["span.street-address", (selector) ->
    bySelector(selector)
  ]
]
streetAddress = chooseOption(addressOptionArray)

localityOptionArray = [
  ["span[property='v:locality']", (selector) ->
    bySelector(selector)
  ]
]
locality = chooseOption(localityOptionArray)

regionOptionArray = [
  ["span[property='v:region']", (selector) ->
    bySelector(selector)
  ]
]
region = chooseOption(regionOptionArray)

postalCodeOptionArray = [
  ["span[property='v:postal-code']", (selector) ->
    bySelector(selector)
  ]
]
postalCode = chooseOption(postalCodeOptionArray)

countryOptionArray = [
  ["span[property='v:country-name']", (selector) ->
    bySelector(selector)
  ]
]
country = chooseOption(countryOptionArray)

phoneOptionArray = [
  ["div.phoneNumber", (selector) ->
    trim(bySelector(selector))
  ]
]
phone = chooseOption(phoneOptionArray)

latLonOptionArray = [
  ["div.STATIC_MAP:visible", (selector) ->
    latLonElement = ifSelector(selector).find("img").attr("src").split("center=")[1].split("&")[0]
    latLonElement.replace("%2C", ',')    
  ],
  ["div#STATIC_MAP:visible", (selector) ->
    latLonElement = ifSelector(selector).find("img").attr("src").split("center=")[1].split("&")[0]
    latLonElement.replace("%2C", ',')    
  ]
]
if chooseOption(latLonOptionArray) && chooseOption(latLonOptionArray).length
  lat = chooseOption(latLonOptionArray).split(",")[0]
  lon = chooseOption(latLonOptionArray).split(",")[1]

# NEEDSFOLLOWUP
#images
imageOptionArray = [
  ["img.heroPhotoImg:visible", (selector) ->
    $(selector).attr("src")
  ],
  ["div.photo_slideshow:visible", (selector) ->
    $(selector).find("img").attr("src")
  ],
  ["img#HERO_PHOTO:visible", (selector) ->
    $(selector).attr("src")
  ]
]
imageList.push( { url: chooseOption(imageOptionArray), source: document.URL, credit: siteName } )
image = chooseOption(imageOptionArray)

ratingInfoOptionArray = [
  ["img.rating_no_fill", (selector) ->
    $(selector).attr('content')
  ]
]
rating = chooseOption(ratingInfoOptionArray)

rankingInfoOptionArray = [
  ["b.rank_text", (selector) ->
    rankingElement = bySelector(selector)
    rankingElement.split("Ranked #")[1]
  ]
]
ranking = chooseOption(rankingInfoOptionArray)

priceInfoOptionArray = [
  ["b:contains('Price range:')", (selector) ->
    $(selector).next().html()
  ]
]
priceInfo = chooseOption(priceInfoOptionArray)

category = document.URL.split("tripadvisor.com/")[1].split("_Review")[0]

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
