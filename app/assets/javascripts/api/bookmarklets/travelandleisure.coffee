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

siteName = "Travel And Leisure"
ratingsBase = ""

nameOptionArray = [
  ['h1', (selector) ->
    trim(bySelector(selector))
  ]
]
name = chooseOption(nameOptionArray)

addressOptionArray = [
  ["div.address", (selector) ->
    $(selector).html().split("<br>")[0]
  ]
]
streetAddress = chooseOption(addressOptionArray)

localityOptionArray = [
  ["div.address", (selector) ->
    $(selector).html().split("<br>")[1].split(',')[0]
  ]
]
locality = chooseOption(localityOptionArray)

# regionOptionArray = [
#   ["span[property='v:region']", (selector) ->
#     bySelector(selector)
#   ]
# ]
# region = chooseOption(regionOptionArray)

# postalCodeOptionArray = [
#   ["span[property='v:postal-code']", (selector) ->
#     bySelector(selector)
#   ]
# ]
# postalCode = chooseOption(postalCodeOptionArray)

countryOptionArray = [
  ["div.address", (selector) ->
    $(selector).html().split("<br>")[1].split(', ')[1]
  ]
]
country = chooseOption(countryOptionArray)

phoneOptionArray = [
  ["div.telephone", (selector) ->
    trim(bySelector(selector).split('<strong class="caps">TEL:</strong>')[1])
  ]
]
phone = chooseOption(phoneOptionArray)

# latLonOptionArray = [
#   ["div#g_map:visible", (selector) ->
#     $(selector).find("a[title='Report errors in the road map or imagery to Google']").attr('href').split("ll=")[1].split("&")[0]
#   ]
# ]
# if chooseOption(latLonOptionArray) && chooseOption(latLonOptionArray).length
#   lat = chooseOption(latLonOptionArray).split(",")[0]
#   lon = chooseOption(latLonOptionArray).split(",")[1]

# imageList = []
# if $("ul.slides") && $("ul.slides").length
#   for image in $("ul.slides").find("img")
#     imageList.push( { url: $(image).attr("src"), source: document.URL, credit: siteName } )
#   image = imageList[0].url

# ratingInfoOptionArray = [
#   ["div.rating", (selector) ->
#     deTag(bySelector(selector))
#   ]
# ]
# rating = chooseOption(ratingInfoOptionArray)

# rankingInfoOptionArray = [
#   ["b.rank_text", (selector) ->
#     rankingElement = bySelector(selector)
#     rankingElement.split("Ranked #")[1]
#   ]
# ]
# ranking = chooseOption(rankingInfoOptionArray)

# sourceNotesOptionArray = [
#   ["li:contains['Style:']", (selector) ->
#     sourceNotesElement = ""
#     sourceNotesElement += deTag(bySelector(selector)).split("Style: ")[1]
#     sourceNotesElement += " & "
#     sourceNotesElement += deTag($(selector).next().html()).split("Atmosphere: ")[1]
#     return sourceNotesElement
#   ]
# ]
# sourceNotes = chooseOption(sourceNotesOptionArray)

# NEEDSFOLLOWUP
# priceInfoOptionArray = [
#   ["li.cost", (selector) ->
#     for dollar in $(selector).find()
#   ]
# ]
# priceInfo = chooseOption(priceInfoOptionArray)

websiteOptionArray = [
  ["div.website", (selector) ->
    $(selector).find("a[target='_blank']").attr("href")
  ]
]
website = chooseOption(websiteOptionArray)

emailOptionArray = [
  ["div.email website", (selector) ->
    $(selector).find("a").attr("href").split("mailto:")[1]
  ]
]
email = chooseOption(emailOptionArray)

#NEEDSFOCUS why not working?
# can also get from URL pop / or div.breadcrumb pop
categoryOptionArray = [
  ["li.level1 active", (selector) ->
    alert("test")
    $(selector).find("span").html()
  ]
]
category = chooseOption(categoryOptionArray)

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
