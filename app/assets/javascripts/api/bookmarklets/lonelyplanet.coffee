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

siteName = "Lonely Planet"
ratingsBase = "1"
# TOP CHOICE BINARY

nameOptionArray = [
  ['h1.copy--h1', (selector) ->
    trim(bySelector(selector))
  ]
]
name = chooseOption(nameOptionArray)

addressOptionArray = [
  ["dt:contains('Address')", (selector) ->
    $(selector).next().html()
  ]
]
streetAddress = chooseOption(addressOptionArray)

localityOptionArray = [
  ["dt:contains('Location')", (selector) ->
    deTag($(selector).next().html()).split(", ")[0]
  ]
]
locality = chooseOption(localityOptionArray)

countryOptionArray = [
  ["dt:contains('Location')", (selector) ->
    deTag($(selector).next().html()).split(", ")[1]
  ]
]
country = chooseOption(countryOptionArray)

phoneOptionArray = [
  ["dt:contains('Telephone')", (selector) ->
    $(selector).next().html()
  ]
]
phone = chooseOption(phoneOptionArray)

latOptionArray = [
  ["div.poi-map__container", (selector) ->
    $(selector).attr("data-latitude")
  ]
]
lat = chooseOption(latOptionArray)

lonOptionArray = [
  ["div.poi-map__container", (selector) ->
    $(selector).attr("data-longitude")
  ]
]
lon = chooseOption(lonOptionArray)

# NEEDSFOLLOWUP
imageList = []
if $("div.slider__container") && $("div.slider__container").length
  for image in $("div.slider__container").find("img")
    imageList.push( { url: $(image).attr("src"), source: document.URL, credit: siteName } )
  image = imageList[0].url
  
ratingInfoOptionArray = [
  ["div.card--top-choice:visible", (selector) ->
    if $(selector) then "Lonely Planet Top Choice"
  ]
]
rating = chooseOption(ratingInfoOptionArray)

priceInfoOptionArray = [
  ["dt:contains('Prices')", (selector) ->
    $(selector).next().html()
  ]
]
priceInfo = chooseOption(priceInfoOptionArray)

websiteOptionArray = [
  ["dt:contains('More information')", (selector) ->
    $(selector).next().find("a").attr("href")
  ]
]
website = chooseOption(websiteOptionArray)

sourceNotesOptionArray = [
  ["dt:contains('Opening hours')", (selector) ->
    return ("Open " + $(selector).next().html().replace("&amp;", "&"))
  ]
]
sourceNotes = chooseOption(sourceNotesOptionArray)

categoryOptionArray = [
  ["div.card--page__breadcrumb", (selector) ->
    categoryOne = bySelector(selector).split(" /")[0].replace("&amp;", "&")
    categoryTwo = $(selector).find("a").html().replace("&amp;", "&")
    return ( categoryOne + ", " + categoryTwo )
  ]
]
if chooseOption(categoryOptionArray) && chooseOption(categoryOptionArray).length
  category = chooseOption(categoryOptionArray).split(", ")

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