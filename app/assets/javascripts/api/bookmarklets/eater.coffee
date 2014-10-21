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

siteName = "Eater"
ratingsBase = ""
# NO RATINGS

nameOptionArray = [
  ['div.m-review-scratch__venue', (selector) ->
    nameElement = $(selector)
    trim(bySelector(selector).split("<h1>")[1].split("</h1>")[0])
  ],
  ["div.m-map-point-title:visible", (selector) ->
    trim(bySelector(selector).split('</span>')[1])
  ]
]
name = chooseOption(nameOptionArray)

addressOptionArray = [
  ["div.address-text:visible", (selector) ->
    bySelector(selector)
  ],
  ["div.m-review-scratch__contact-group", (selector) ->
    trim(deTag(bySelector(selector)))
  ]
]
streetAddress = chooseOption(addressOptionArray)

localityOptionArray = [
  ["div.address-text:visible", (selector) ->
    trim(bySelector($(selector)[1]).split(", ")[0])
  ]
]
locality = chooseOption(localityOptionArray)

postalCodeOptionArray = [
  ["div.address-text:visible", (selector) ->
    trim(bySelector($(selector)[1]).split(", ")[1])
  ]
]
postalCode = chooseOption(postalCodeOptionArray)

countryOptionArray = [
  ["div.address-text:visible", (selector) ->
    trim(bySelector($(selector)[1]).split(", ")[2])
  ]
]
country = chooseOption(countryOptionArray)

imageOptionArray = [
  ["div.l-review-head__image:visible", (selector) ->
    $(selector).find("img").attr("data-original")
    # cycle through all images with class vox-lazy-load
  ],
  ["div.m-map-point-image:visible", (selector) ->
    $(selector).attr('style').split("url('")[1].split("')")[0]
  ]
]
imageList.push( { url: chooseOption(imageOptionArray), source: document.URL, credit: "Eater" } )
photoToUse = chooseOption(imageOptionArray)

priceInfoOptionArray = [
  ["dt:contains('Cost')", (selector) ->
    if $(selector) && $(selector).length
      $(selector).next().html()
  ]
]
priceInfo = chooseOption(priceInfoOptionArray)

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
