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

siteName = "Fodors"
ratingsBase = "1"
# FODOR'S CHOICE IS BINARY

nameOptionArray = [
  ['h1.poi-title', (selector) ->
    trim(bySelector(selector))
  ]
]
name = chooseOption(nameOptionArray)

# address
# $("h1.poi-title").next() <- just street address
addressOptionArray = [
  ["p.poi-info-title:contains('Address:')", (selector) ->
    $(selector).next().html()
  ]
]
fullAddress = chooseOption(addressOptionArray)
if fullAddress && fullAddress.length
  streetAddress = fullAddress.split(", ")[0]
  locality = fullAddress.split(", ")[1]
  postalCode = fullAddress.split(", ")[2]
  country = fullAddress.split(", ")[3]

phoneOptionArray = [
  ["p.poi-info-title:contains('Phone')", (selector) ->
    $(selector).next().html()
  ]
]
phone = chooseOption(phoneOptionArray)

websiteOptionArray = [
  ["div.poi-info-website", (selector) ->
    $(selector).find("a").attr("href")
  ]
]
website = chooseOption(websiteOptionArray)

latLonOptionArray = [
  ["div#static-map:visible", (selector) ->
    $(selector).find("img").attr("src").split("|")[1].split("&")[0].replace("%2C", ',')
  ]
]
if chooseOption(latLonOptionArray) && chooseOption(latLonOptionArray).length
  lat = chooseOption(latLonOptionArray).split(",")[0]
  lon = chooseOption(latLonOptionArray).split(",")[1]

sourceNotesOptionArray = [
  ["strong.poi-info-title:contains('Sight Details')", (selector) ->
    trim(deTag($(selector).parent().next().html()))
  ]
]
sourceNotes = chooseOption(sourceNotesOptionArray)

if $("li.fodors-choice:visible") && $("li.fodors-choice:visible").length
  ranking = "Fodors Choice"

# NEEDSFOLLOWUP <-- COUNT ONLY POI TAGS NOT POPULAR TAGS
# categoryInfoOptionArray = [
#   ["div.poi-tag", (selector) ->
#     deTag(bySelector(selector))
#     # ALLOW MULTIPLE?
#   ]
# ]
# if chooseOption(categoryInfoOptionArray) && chooseOption(categoryInfoOptionArray).length
#   category = chooseOption(categoryInfoOptionArray).split(', ')

# NO PHOTOS

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
