siteName = "National Geographic"
ratingsBase = ""

imageContainerArray = ["div.primary_photo"]
getImages(imageContainerArray)
if imageList && imageList.length
  photoToUse = imageList[0].url

headerContentOptionArray = [
  ["header:visible", (selector) ->
    bySelector(selector)
  ],
  ["div.page_head:visible", (selector) ->
    bySelector(selector)
  ]
]
headerContent = chooseOption(headerContentOptionArray)
if headerContent && headerContent.length
  name = deTag(headerContent.split("<h1")[1].split("</h1>")[0]).split(">")[1]
  if headerContent.split('location">')[1].length
    fullAddress = trim(deTag(headerContent.split('location">')[1]))
    fullAddressArray = fullAddress.split(",")
    country = fullAddressArray.pop()
    locality = fullAddressArray.pop()
    streetAddress = fullAddressArray.join()

fullAddressOptionArray = [
  ["p.meta location", (selector) ->
    bySelector(selector)
  ],
  ["strong:contains['Location: ']", (selector) ->
    bySelector(selector).split("Location: ")[1]
  ]
]
if chooseOption(fullAddressOptionArray) && chooseOption(fullAddressOptionArray).length
  fullAddress = chooseOption(fullAddressOptionArray)

# NEEDSFOLLOWUP

# websiteOptionArray = [
#   ["a[data-google-action='Clicked external URL',data-google-category='Place Detail Page']", (selector) ->
#     $(selector).attr("href")
#   ],
#   ["div.title:contains('Website')", (selector) ->
#     $(selector).next().find("a").attr("href")
#   ]
# ]
# website = chooseOption(websiteOptionArray)

# phoneOptionArray = [
#   ["div.title:contains('Phone')", (selector) ->
#     $(selector).next().html()
#   ]
# ]
# phone = chooseOption(websiteOptionArray)

# latLonOptionArray = [
#   ["div.map", (selector) ->
#     latLonElement = ifSelector(selector).find("a").attr("href").split("&q=")[1]
#     latLonElement.replace("%2C", ',')    
#   ],
#   ["div.map-details", (selector) ->
#     latLonElement = ifSelector(selector).find("a").attr("href").split("&q=")[1]
#     latLonElement.replace("%2C", ',')    
#   ]
# ]
# if chooseOption(latLonOptionArray) && chooseOption(latLonOptionArray).length
#   lat = chooseOption(latLonOptionArray).split(",")[0]
#   lon = chooseOption(latLonOptionArray).split(",")[1]

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
  imageList: imageList
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