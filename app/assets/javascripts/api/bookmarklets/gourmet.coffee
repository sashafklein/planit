siteName = "Gourmet"
ratingsBase = ""
# NO APPARENT RATINGS

infoOptionArray = [
  ['div#articletext', (selector) ->
    $(selector)
  ],
  ['div.item-text', (selector) ->
    $(selector)
  ]
]
if chooseOption(infoOptionArray) && chooseOption(infoOptionArray).length 
  articleBody = chooseOption(infoOptionArray).html()
  infoLine = articleBody.split("<strong>")[1]
  if infoLine && infoLine.length
    name = deTag(infoLine.split("</strong>")[0])
    streetAddress = infoLine.split("</strong>")[1].split(",")[0]
    locality = infoLine.split(", ")[1].split("(")[0]
    phone = infoLine.split("(")[1].split(";")[0]
    website = infoLine.split('href="')[1].split('"')[0]

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
