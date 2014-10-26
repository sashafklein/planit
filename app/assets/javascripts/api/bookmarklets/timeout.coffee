siteName = "Time Out"
ratingsBase = ""

nameOptionArray = [
  ["h1.listing_page_title", (selector) ->
    bySelector(selector)
  ],
  ["h1[itemprop='name']", (selector) ->
    bySelector(selector)
  ]  
]
name = chooseOption(nameOptionArray)

fullAddressOptionArray = [
  ["address", (selector) ->
    bySelector(selector)
  ]
]
fullAddressElement = chooseOption(fullAddressOptionArray)
if fullAddressElement && fullAddressElement.length
  fullAddress = trim( deTag( fullAddressElement.html() ) )

imageListElement = []
imageList = []
imagesOptionArray = [
  ["div.hero", (selector) ->
    for image in $(selector).find("img")
      imageListElement.push( { url: $(image).attr("src"), source: document.URL, credit: siteName } )
    return imageListElement
  ],
  ["div.flex-viewport", (selector) ->
    for image in $(selector).find("img")
      imageListElement.push( { url: $(image).attr("src"), source: document.URL, credit: siteName } )
    return imageListElement
  ]  
]
imageList = chooseOption(imagesOptionArray)
if imageList && imageList.length
  alert(imageList[0].url)
  photoToUse = imageList[0].url
  
categoryOptionArray = [
  ["ul.page_tag", (selector) ->
    $(selector)
  ]
]
if chooseOption(categoryOptionArray) && chooseOption(categoryOptionArray).length
  for catItem in chooseOption(categoryOptionArray).find("li")
    category.push bySelector(catItem)

rankingOptionArray = [
  ["div.critics_choice:visible", (selector) ->
    bySelector(selector)
  ]
]
if chooseOption(rankingOptionArray) && chooseOption(rankingOptionArray).length
  ranking = trim( deTag( chooseOption(rankingOptionArray) ) )

ratingOptionArray = [
  ["div[itemprop='ratingValue']", (selector) ->
    bySelector(selector)
  ]
]
rating = chooseOption(ratingOptionArray)

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