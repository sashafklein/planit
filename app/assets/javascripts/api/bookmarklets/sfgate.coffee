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

siteName = "SF Gate"
ratingsBase = ""
# NO APPARENT RATINGS

if $("p:contains('strong:contains('Where')')") && $("p:contains('strong:contains('Where')')").length
  alert("hey")
  whereText = $("p:contains('strong:contains('Where')')")
  alert(whereText.parent().html())

# nameOptionArray = [
#   [whereText, (selector) ->
#     $(selector).find("strong:contains('Where:')")
#   ]
# ]
# name = chooseOption(nameOptionArray)

# priceInfoOptionArray = [
#   ["span:contains('from $')", (selector) ->
#     bySelector(selector).split('from ')[1]
#   ]
# ]
# priceInfo = chooseOption(priceInfoOptionArray)

# category = 'hotel'

# ratingOptionArray = [
#   ["span.score", (selector) ->
#     bySelector(selector)
#   ]
# ]
# rating = chooseOption(ratingOptionArray)

# rankingOptionArray = [
#   ["p:contains('say expert reviewers')", (selector) ->
#     $(selector).next().html()
#   ]
# ]
# if chooseOption(rankingOptionArray) && chooseOption(rankingOptionArray).length
#   ranking = chooseOption(rankingOptionArray).split("#")[1].split(" in")[0]

# fullAddressOptionArray = [
#   ["p.address", (selector) ->
#     deBreak(deTag(bySelector(selector)))
#   ]
# ]
# if chooseOption(fullAddressOptionArray) && chooseOption(fullAddressOptionArray).length
#   fullAddress = chooseOption(fullAddressOptionArray).split(", ")
#   country = fullAddress.pop()
#   locality = fullAddress.pop()
#   streetAddress = fullAddress.join(", ")

# # city
# # $("ul.breadcrumb") <- 1st li
# # country
# # $("ul.breadcrumb") <- 2nd li

# imageList = []
# if $("ul.slides") && $("ul.slides").length
#   for image in $("ul.slides").find("img")
#     imageList.push( { url: $(image).attr("src"), source: document.URL, credit: siteName } )
#   image = imageList[0].url
  
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