siteName = "LA Times"
ratingsBase = ""

articleContentOptionArray = [
  ["div[itemprop='article']", (selector) ->
    bySelector(selector)
  ]
]
articleContent = chooseOption(articleContentOptionArray)
if articleContent && articleContent.length
  if articleContent.indexOf("Info: ") != '-1'
    name = deTag(articleContent.split("Info: ")[1].split(",")[0])
  else if articleContent.indexOf("<strong>If You go</strong>") != '-1'
    name = deTag(articleContent.split("<strong>If You go</strong>")[1].split(",")[0])
  if articleContent.split("Info: ")[1].indexOf("href=") != '-1'
    website = trim(articleContent.split('href="')[1].split('"')[0]) 
  # if articleContent.split("(")[1].indexOf(")") == '4'
  #   phone = trim(articleContent.split('(')[1].split('.')[0]) 
  # NEEDSFOLLOWUP
  # if articleContent.indexOf(" at ") != '-1'
  #   localityGuess = articleContent.split(" at ")[1].split(" ")[0]
  # if articleContent.indexOf(" in ") != '-1'
  #   localityGuess = articleContent.split(" in ")[1].split(" ")[0]
locality = "X"

# fullAddressOptionArray = [
#   ["p.meta location", (selector) ->
#     bySelector(selector)
#   ],
#   ["strong:contains['Location: ']", (selector) ->
#     bySelector(selector).split("Location: ")[1]
#   ]
# ]
# if chooseOption(fullAddressOptionArray) && chooseOption(fullAddressOptionArray).length
#   fullAddress = chooseOption(fullAddressOptionArray)

imageListElement = []
imageList = []
imagesOptionArray = [
  ["div.trb_embed_media", (selector) ->
    for image in $(selector).find("img")
      imageListElement.push( { url: $(image).attr("src"), source: document.URL, credit: siteName } )
    return imageListElement
  ]
]
imageList = chooseOption(imagesOptionArray)
if imageList && imageList.length
  photoToUse = imageList[0].url
  
# phoneOptionArray = [
#   ["p:contains['Info: ']", (selector) ->
#     nameElement = bySelector(selector)
#     deTag(nameElement).split("#{name}, ")[1].split(".")[0]
#   ]
# ]
# phone = chooseOption(phoneOptionArray)

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