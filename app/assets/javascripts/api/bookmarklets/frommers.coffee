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

siteName = "Frommers"
ratingsBase = "3"

nameOptionArray = [
  ['h1.articleTitle', (selector) ->
    trim(bySelector(selector))
  ]
]
name = chooseOption(nameOptionArray)

# NEEDSFOLLOWUP <- NOT REAL ADDRESS, WILL NEED CLEANING/PARSING
addressOptionArray = [
  ["h1.articleTitle", (selector) ->
    $(selector).next().html()
  ]
]
address = chooseOption(addressOptionArray)

ratingOptionArray = [
  ["h1", (selector) ->
    $(selector).find("img").attr("src").split("star_meter")[1].split(".")[0]
  ]
]
rating = chooseOption(ratingOptionArray)


# NEEDSFOLLOWUP
# if $("div.breadcrumbs row") && $("div.breadcrumbs row").length
#   breadCrumbElements = $("div.breadcrumbs row").html()
#   breadCrumbToParse = deTag(breadCrumbElements).split("Destinations")[1]
#   alert(breadCrumbToParse)

# NO LOCALITY ???
# NO REGION
# NO COUNTRY ???
# NO PHONE 
# NO WEBSITE
# NO LATLON
# NO IMAGE

# NEEDSFOLLOWUP
# SOURCE DETAILS
# $("strong.poi-info-title:contains('Sight Details')").next()

testAlert = [
  name
  streetAddress
  locality
  region
  postalCode
  country
  phone
  website
  category
  priceInfo
  sourceNotes
  rating
  ranking
  imageList
  photoToUse
  lat
  lon
].join("/")
alert(testAlert)
  
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
