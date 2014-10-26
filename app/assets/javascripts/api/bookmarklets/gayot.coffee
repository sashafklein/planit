siteName = "Gayot"
ratingsBase = ""

nameOptionArray = [
  ['h1', (selector) ->
    bySelector(selector)
  ]
]
name = chooseOption(nameOptionArray)

# NEEDSFOLLOWUP <-- pop off phone numbers, parse address?
fullAddress = cleanDetailBox("div#nameAddress", ["Send to Phone", "RESERVE NOW!", "|", "View Website", "Rating", name])

website = getWebsite("View Website", "div#nameAddress")

imageContainer = ["table#mainText"]
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