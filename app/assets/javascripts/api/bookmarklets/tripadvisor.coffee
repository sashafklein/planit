
latLonOptionArray = [
  ["div.STATIC_MAP:visible", (selector) ->
    latLonElement = $(selector).find("img").attr("src").split("center=")[1].split("&")[0]
    latLonElement.replace("%2C", ',')    
  ],
  ["div#STATIC_MAP:visible", (selector) ->
    latLonElement = $(selector).find("img").attr("src").split("center=")[1].split("&")[0]
    latLonElement.replace("%2C", ',')    
  ]
]
if chooseOption(latLonOptionArray) && chooseOption(latLonOptionArray).length
  lat = chooseOption(latLonOptionArray).split(",")[0]
  lon = chooseOption(latLonOptionArray).split(",")[1]

# NEEDSFOLLOWUP
#images

imageListElement = []
imageList = []
imagesOptionArray = [
  ["div.sizedThumb_container", (selector) ->
    for image in $(selector).find("img")
      imageListElement.push( { url: $(image).attr("src"), source: document.URL, credit: siteName } )
    return imageListElement
  ],
  ["div.photo_slideshow", (selector) ->
    for image in $(selector).find("img")
      imageListElement.push( { url: $(image).attr("src"), source: document.URL, credit: siteName } )
    return imageListElement
  ],
  ["div.photoGrid.photoBx", (selector) ->
    for image in $(selector).find("img")
      imageListElement.push( { url: $(image).attr("src"), source: document.URL, credit: siteName } )
    return imageListElement
  ]
]
imageList = chooseOption(imagesOptionArray)
if imageList && imageList.length
  photoToUse = imageList[0].url
