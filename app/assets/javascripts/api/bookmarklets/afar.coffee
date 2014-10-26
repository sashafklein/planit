siteName = "AFAR"
ratingsBase = ""

nameOptionArray = [
  ["div.place-title", (selector) ->
    bySelector(selector)
  ],
  ["h1", (selector) ->
    bySelector(selector)
  ]
]
name = chooseOption(nameOptionArray)

websiteOptionArray = [
  ["a[data-google-action='Clicked external URL',data-google-category='Place Detail Page']", (selector) ->
    $(selector).attr("href")
  ],
  ["div.title:contains('Website')", (selector) ->
    $(selector).next().find("a").attr("href")
  ]
]
website = chooseOption(websiteOptionArray)

phoneOptionArray = [
  ["div.title:contains('Phone')", (selector) ->
    $(selector).next().html()
  ]
]
phone = chooseOption(websiteOptionArray)

fullAddressOptionArray = [
  ["div.place-address", (selector) ->
    bySelector(selector)
  ],
  ["div.address", (selector) ->
    bySelector(selector)
  ]
]
if chooseOption(fullAddressOptionArray) && chooseOption(fullAddressOptionArray).length
  fullAddress = chooseOption(fullAddressOptionArray)
  if fullAddress.split("<br>").length >= 1
    firstLine = fullAddress.split("<br>")[0] 
    secondLine = fullAddress.split("<br>")[1]
  if firstLine.split(",").length >= 2
    streetAddress = firstLine.split(",")[0]
    locality = firstLine.split(",")[1]
  else
    streetAddress = firstLine
  if secondLine.split(",").length >= 3
    locality = secondLine.split(",")[0]
    region = secondLine.split(",")[1]
    country = secondLine.split(",")[2]
  else if secondLine.split(",").length >= 2
    region = secondLine.split(",")[0]
    country = secondLine.split(",")[1]
  else
    locality = secondLine

latLonOptionArray = [
  ["div.map", (selector) ->
    latLonElement = ifSelector(selector).find("a").attr("href").split("&q=")[1]
    latLonElement.replace("%2C", ',')    
  ],
  ["div.map-details", (selector) ->
    latLonElement = ifSelector(selector).find("a").attr("href").split("&q=")[1]
    latLonElement.replace("%2C", ',')    
  ]
]
if chooseOption(latLonOptionArray) && chooseOption(latLonOptionArray).length
  lat = chooseOption(latLonOptionArray).split(",")[0]
  lon = chooseOption(latLonOptionArray).split(",")[1]

imageListElement = []
imageList = []
imagesOptionArray = [
  ["ul.slides", (selector) ->
    for image in $(selector).find("img")
      imageListElement.push( { url: $(image).attr("src"), source: document.URL, credit: siteName } )
    return imageListElement
  ],
  ["div.slick-slide", (selector) ->
    for image in $(selector).find("img")
      imageListElement.push( { url: $(image).attr("src"), source: document.URL, credit: siteName } )
    return imageListElement
  ]
]
imageList = chooseOption(imagesOptionArray)
if imageList.length
  photoToUse = imageList[0].url
  
# priceInfoOptionArray = [
#   ["span:contains('from $')", (selector) ->
#     bySelector(selector).split('from ')[1]
#   ]
# ]
# priceInfo = chooseOption(priceInfoOptionArray)

# categoryOptionArray = [
#   ["span.score", (selector) ->
#     bySelector(selector)
#   ]
# ]
# category = chooseOption(categoryOptionArray)

# ratingOptionArray = [
#   ["span.score", (selector) ->
#     bySelector(selector)
#   ]
# ]
# rating = chooseOption(ratingOptionArray)

# rankingOptionArray = [
#   ["p:contains('say expert reviewers')", (selector) ->
#     $(selector).next().html()
#   ]
# ]
# if chooseOption(rankingOptionArray) && chooseOption(rankingOptionArray).length
#   ranking = chooseOption(rankingOptionArray).split("#")[1].split(" in")[0]

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