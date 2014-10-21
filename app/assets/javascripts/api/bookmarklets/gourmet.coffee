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

siteName = "Gourmet"
ratingsBase = ""
# NO APPARENT RATINGS

nameOptionArray = [
  ['div.item-text', (selector) ->
    $(selector).find("strong").find("em").html()
  ]
]
name = chooseOption(nameOptionArray)

addressOptionArray = [
  ['div.item-text', (selector) ->
    $(selector).find("strong").find("em").next()
    # NEEDFOLLOWUP
  ]
]
address = chooseOption(addressOptionArray)
streetAdress = address.split(", ")[0]
locality = address.split(", ")[1]
phone = address.split("(")[1].split(";")[0]
website = address.find("a").attr("href")

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
