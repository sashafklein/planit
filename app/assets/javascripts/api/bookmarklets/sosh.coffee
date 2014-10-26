siteName = "Sosh"
ratingsBase = ""

name = getSubSelector("section#activity-details", "div#activity-title")

localNameOptionArray = [
  ["div#name", (selector) ->
    $(selector).find("div#localName").html()
  ]
]
localName = chooseOption(localNameOptionArray)

addressOptionArray = [
  ["div#venue-profile", (selector) ->
    $(selector).find("div#address").html()
  ]
]
streetAddress = chooseOption(addressOptionArray)

fullAddressOptionArray = [
  ["a#get-directions", (selector) ->
    $(selector).attr("href").split("daddr=")[1]
  ]
]
fullAddress = unescape ( chooseOption(fullAddressOptionArray) )

sourceNotes = cleanDetailBox("#summary-bar", [name])

imageContainer = ["div#activity-image-main"]
getGalleryImages(imageContainer)
if imageList && imageList.length
  photoToUse = imageList[0].url

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