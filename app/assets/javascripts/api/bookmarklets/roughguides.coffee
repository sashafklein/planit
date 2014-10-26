siteName = "Rough Guide"
ratingsBase = ""

nameOptionArray = [
  ["h1.page-title:visible", (selector) ->
    bySelector(selector)
  ]
]
name = chooseOption(nameOptionArray)

countryOptionArray = [
  ["a.country", (selector) ->
    trim(bySelector(selector).replace("//", ""))
  ]
]
country = chooseOption(countryOptionArray)

locality = "x"
# localityOptionArray = [
#   ["span[itemprop='addressLocality']", (selector) ->
#     bySelector(selector)
#   ]
# ]
# locality = chooseOption(localityOptionArray)

# postalCodeOptionArray = [
#   ["span[itemprop='postalCode']", (selector) ->
#     bySelector(selector)
#   ]
# ]
# postalCode = chooseOption(postalCodeOptionArray)

# regionOptionArray = [
#   ["span[itemprop='addressRegion']", (selector) ->
#     bySelector(selector)
#   ]
# ]
# region = chooseOption(regionOptionArray)

# articleContentOptionArray = [
#   ["div#reviewNum1", (selector) ->
#     bySelector(selector)
#   ]
# ]
# articleContent = chooseOption(articleContentOptionArray)
# if articleContent && articleContent.length
#   articleText = deTag(articleContent)

# imageListElement = []
# imageList = []
# imagesOptionArray = [
#   ["div#large-image-wrapper", (selector) ->
#     for image in $(selector).find("img")
#       imageListElement.push( { url: $(image).attr("src"), source: document.URL, credit: siteName } )
#     return imageListElement
#   ]
# ]
# imageList = chooseOption(imagesOptionArray)
# if imageList && imageList.length
#   photoToUse = imageList[0].url
  
# # phoneOptionArray = [
# #   ["span:contains['WILDCARDS']", (selector) ->
# #     bySelector(selector)
# #   ]
# # ]
# # phone = chooseOption(phoneOptionArray)

# websiteOptionArray = [
#   ["a[omniture='profile location - default - overview - website']", (selector) ->
#     $(selector).attr("href")
#   ]
# ]
# website = chooseOption(websiteOptionArray)

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

# priceInfoOptionArray = [
#   ["span.orange", (selector) ->
#     bySelector(selector)
#   ]
# ]
# priceInfo = chooseOption(priceInfoOptionArray)

# categoryOptionArray = [
#   ["div.subcategory", (selector) ->
#     bySelector(selector)
#   ]
# ]
# category = chooseOption(categoryOptionArray)

# rankingOptionArray = [
#   ["div.editors-pick-icon:visible", (selector) ->
#     bySelector(selector)
#   ]
# ]
# if chooseOption(rankingOptionArray) && chooseOption(rankingOptionArray).length
#   ranking = "Editor's Pick"

# sourceNotesOptionArray = [
#   ["div.dates-and-times", (selector) ->
#     bySelector(selector)
#   ]
# ]
# if chooseOption(sourceNotesOptionArray) && chooseOption(sourceNotesOptionArray).length
#   sourceNotes = trim(deTag(chooseOption(sourceNotesOptionArray)))

return {
  name: name
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