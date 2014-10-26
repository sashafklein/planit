siteName = "SF Gate"
ratingsBase = ""
# NO APPARENT RATINGS

if $("p:contains('strong:contains('Where')')")
  whereText = deTag($("p:contains('Where')").html())
  name = whereText.split('Where: ')[1].split(',')[0]
  streetAddress = whereText.split("#{name}, ")[1].split(',')[0]
  locality = whereText.split("#{streetAddress}, ")[1].split(' (')[0]
  phone = whereText.split("#{locality} ")[1].split('.')[0]
  website = $("p:contains('Where')").find("a").attr("href")

if $("p:contains('strong:contains('When')')")
  whenText = deTag($("p:contains('When')").html())
  sourceNotes = whenText.split("When: ")[1]

imageList = []
if $("ul.hst-resgallery") && $("ul.hst-resgallery").length
  for image in $("ul.hst-resgallery").find("img")
    imageList.push( { url: $(image).attr("src"), source: document.URL, credit: siteName } )
  image = imageList[0].url
  
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