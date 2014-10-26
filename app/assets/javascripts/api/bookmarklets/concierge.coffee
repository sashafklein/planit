siteName = "Concierge.com"
ratingsBase = ""
name = "test"
locality = "test"

headerContentOptionArray = [
  ["div.detailHeading:visible", (selector) ->
    bySelector(selector)
  ]
]
headerContent = chooseOption(headerContentOptionArray)
if headerContent && headerContent.length
  if headerContent.indexOf("<h3") != "-1" then name = deTag(headerContent.split("<h3")[1].split(",")[0]).split(">")[1]
  if headerContent.split('<span class="ldn">')[1].split("</span")[0] then locality = headerContent.split('span class="ldn">')[1].split("</span")[0]

fullAddressOptionArray = [
  ["div.propertyAddress", (selector) ->
    bySelector(selector)
  ]
]
fullAddressElement = chooseOption(fullAddressOptionArray)
if fullAddressElement && fullAddressElement.length
  # NEEDSFOLLOWUP
  # if fullAddressElement.indexOf("Tel: ") != "-1" then fullAddressElement1 = fullAddressElement.split("Tel: ")[0]
  # if fullAddressElement1.indexOf("<a ") != "-1" then fullAddressElement2 = fullAddressElement1.split("<a ")[0]
  fullAddress = trim( deTag( fullAddressElement.replace("<br>", ",") ) )

websiteOptionArray = [
  ["a:contains('view web site')", (selector) ->
    $(selector).attr("href")
  ]
]
website = chooseOption(websiteOptionArray)

imageListElement = []
imageList = []
imagesOptionArray = [
  ["div#propertyPhoto", (selector) ->
    for image in $(selector).find("img")
      imageListElement.push( { url: $(image).attr("src"), source: document.URL, credit: siteName } )
    return imageListElement
  ]
]
imageList = chooseOption(imagesOptionArray)
if imageList && imageList.length
  photoToUse = imageList[0].url
  
if fullAddressElement.indexOf("Tel: ") != "-1"
  phone = fullAddressElement.split("Tel: ")[1].split("<br>")[0]

latLonOptionArray = [
  ["div#map_canvas", (selector) ->
    if $(selector).find("a").attr("href")
      latLonElement = $(selector).find("a").attr("href")
      latLonElement.split("ll=")[1].split("&")[0].replace("%2C", ',')    
  ]
]
if chooseOption(latLonOptionArray) && chooseOption(latLonOptionArray).length
  lat = chooseOption(latLonOptionArray).split(",")[0]
  lon = chooseOption(latLonOptionArray).split(",")[1]

priceInfoOptionArray = [
  ["div.costRating", (selector) ->
    bySelector(selector)
  ]
]
priceInfoElement = chooseOption(priceInfoOptionArray)
if priceInfoElement && priceInfoElement.length
  priceInfo = priceInfoElement.split('<span class="off">')

categoryOptionArray = [
  ["h3.yellowHeadline", (selector) ->
    bySelector(selector)
  ]
]
category = chooseOption(categoryOptionArray)

rankingOptionArray = [
  ["div.headlineMeta:visible:contains('headlineMeta')", (selector) ->
    bySelector(selector)
  ]
]
if chooseOption(rankingOptionArray) && chooseOption(rankingOptionArray).length
  ranking = "Editor's Pick"

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