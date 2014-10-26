siteName = "TripAdvisor"
ratingsBase = "5"

nameOptionArray = [
  ["h1#HEADING", (selector) ->
    bySelector(selector)
  ]
]
nameElement = chooseOption(nameOptionArray)
name = nameElement.replace(/(\r\n|\n|\r)/gm, '')

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
    latLonElement = $(selector).find("img").attr("src").split("center=")[1].split("&")[0]
    latLonElement.replace("%2C", ',')    
  ],
  ["div#STATIC_MAP:visible", (selector) ->
    latLonElement = $(selector).find("img").attr("src").split("center=")[1].split("&")[0]
    latLonElement.replace("%2C", ',')    
  ]
]
if chooseOption(latLonOptionArray) && chooseOption(latLonOptionArray).length
  lat = chooseOption(latLonOptionArray).split(",")[0]
  lon = chooseOption(latLonOptionArray).split(",")[1]

# NEEDSFOLLOWUP
#images

imageListElement = []
imageList = []
imagesOptionArray = [
  ["div.sizedThumb_container", (selector) ->
    for image in $(selector).find("img")
      imageListElement.push( { url: $(image).attr("src"), source: document.URL, credit: siteName } )
    return imageListElement
  ],
  ["div.photo_slideshow", (selector) ->
    for image in $(selector).find("img")
      imageListElement.push( { url: $(image).attr("src"), source: document.URL, credit: siteName } )
    return imageListElement
  ],
  ["div.photoGrid.photoBx", (selector) ->
    for image in $(selector).find("img")
      imageListElement.push( { url: $(image).attr("src"), source: document.URL, credit: siteName } )
    return imageListElement
  ]
]
imageList = chooseOption(imagesOptionArray)
if imageList && imageList.length
  photoToUse = imageList[0].url

ratingInfoOptionArray = [
  ["img.rating_no_fill", (selector) ->
    $(selector).attr('content')
  ]
]
rating = chooseOption(ratingInfoOptionArray)

rankingInfoOptionArray = [
  ["b.rank_text", (selector) ->
    rankingElement = bySelector(selector)
    if rankingElement && rankingElement.length && rankingElement.indexOf("Ranked #") != "-1"
      rankingElement.split("Ranked #")[1]
    else null
  ]
]
ranking = chooseOption(rankingInfoOptionArray)

priceInfoOptionArray = [
  ["b:contains('Price range:')", (selector) ->
    $(selector).next().html()
  ]
]
priceInfo = chooseOption(priceInfoOptionArray)

category.push document.URL.split("tripadvisor.com/")[1].split("_Review")[0]

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