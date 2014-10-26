siteName = "Stay.com"
ratingsBase = "5"

name = getSubSelector("div.section-info", "h1")

locality = cleanDetailBox("div.details", ["Price:", "Cost money", name, fullAddress])

# NEEDSFOLLOWUP -> GET IN DETAILS BOX FOR MORE INFO
# priceInfoOptionArray = [
#   ["span:contains('from $')", (selector) ->
#     bySelector(selector).split('from ')[1]
#   ]
# ]
# priceInfo = chooseOption(priceInfoOptionArray)

# sourceNotesOptionArray = [
#   ["span:contains('from $')", (selector) ->
#     bySelector(selector).split('from ')[1]
#   ]
# ]
# sourceNotes = chooseOption(sourceNotesOptionArray)

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

fullAddressOptionArray = [
  ["div.address", (selector) ->
    trim( deTag( bySelector(selector) ) )
  ]
]
if chooseOption(fullAddressOptionArray) && chooseOption(fullAddressOptionArray).length
  fullAddressElement = chooseOption(fullAddressOptionArray)
  fullAddress = trim( deTag( fullAddressElement.replace(" (show map)", "") ) )

if $("div.details") && $("div.details").length
  detailBox = $("div.details")

  unless fullAddress && fullAddress.length 
    fullAddressElement = detailBox.html().split("</strong>")[1].split("</p>")[0]
    fullAddress = trim( deTag( fullAddressElement ) )

if document.URL.indexOf("/") > 4
  categoryElement = document.URL
  category.push categoryElement.split("/")[4].split("/")[0]

imageList = []
if $("div.inline-gallery-container") && $("div.inline-gallery-container").length
  for image in $("div.inline-gallery-container").find("img")
    imageList.push( { url: $(image).attr("src"), source: document.URL, credit: siteName } )
  image = imageList[0].url

unless imageList && imageList.length 
  if $("div.gallery") && $("div.gallery").length
    for image in $("div.gallery").find("img")
      imageList.push( { url: $(image).attr("src"), source: document.URL, credit: siteName } )
    image = imageList[0].url

latLonOptionArray = [
  ["div.static-map", (selector) ->
    if $(selector) && $(selector).length
      latLonElement = $(selector).find("img").attr("src").split("center=")[1].split("&")[0]
      latLonElement.replace("%2C", ',')    
  ]
]
if chooseOption(latLonOptionArray) && chooseOption(latLonOptionArray).length
  lat = chooseOption(latLonOptionArray).split(",")[0]
  lon = chooseOption(latLonOptionArray).split(",")[1]

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