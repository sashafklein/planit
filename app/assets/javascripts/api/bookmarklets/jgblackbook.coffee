siteName = "JG Black Book"
ratingsBase = ""

nameOptionArray = [
  ['span.destination-info', (selector) ->
    $(selector).find("h1").html()
  ]
]
name = chooseOption(nameOptionArray)

fullAddressOptionArray = [
  ['span.destination-info', (selector) ->
    $(selector).find("h2").html()
  ]
]
fullAddress = chooseOption(fullAddressOptionArray)

websiteOptionArray = [
  ['span.destination-info', (selector) ->
    $(selector).find("a.external").attr("href")
  ]
]
website = chooseOption(websiteOptionArray)

imageContainer = ["div.slideshow"]
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