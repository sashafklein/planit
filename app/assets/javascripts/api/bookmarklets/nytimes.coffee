siteName = "NYTimes"
ratingsBase = ""
path = document.URL

pageList = []
splitByOptions = [["36 Hours in ", "1"], ["36 Hours at the ", "1"], ["36 Hours on ", "1"], ["36 Hours | ", "1"]]

# ~2003 instance without detail box
if path.indexOf("/travel/") != -1 && path.indexOf("journeys-36-hours") != -1

  locationBest = splitBy("h1", splitByOptions)
  # NEEDSFOLLOWUP DATEPUBLISHED

  groupArray = []

  focusArea = textSelector("#area-main")

  if focusArea && focusArea.length
    days = []
    if focusArea.indexOf("Friday") != -1 && focusArea.indexOf("Saturday") != -1 && focusArea.indexOf("Sunday") != -1
      if focusArea.indexOf("IF YOU GO") != -1 || focusArea.indexOf("THE BASICS") != -1
        days.push focusArea.split(/\nFriday\n/)[1].split(/\nSaturday\n/)[0]
        days.push focusArea.split(/\nSaturday\n/)[1].split(/\nSunday\n/)[0]
        days.push focusArea.split(/\nSunday\n/)[1].split(/\nTHE\sBASICS\n|\nIF\sYOU\sGO\n/i)[0]
      else 
        days.push focusArea 

      dayNumber = 0
      for day in days
        dayNumber = dayNumber + 1
        groupTimeArray = day.match(/\n\d?\d?:?\d?\d\s[ap]\.[m]\.|\n[N][o][o][n]/g)
        groupSectionArray = day.split(/\n\d?\d?:?\d?\d\s[ap]\.[m]\.|\n[N][o][o][n]/g)
        groupSectionArray = groupSectionArray.filter( (n) -> n != '' ) 
        if groupTimeArray && groupSectionArray && groupTimeArray.length == groupSectionArray.length
          i = 0
          while i < groupTimeArray.length
            time = trim( groupTimeArray[i] )
            content = groupSectionArray[i]
            groupArray.push [ time, content ]
            i++
          for group in groupArray
            groupActivities = group[1].match(/(((?:[S][t]\a?\.\s)?[A-ZÄÀÁÇÈÉëÌÍÖÒÓ][a-zäàáçèéëìíöòó,']+(?=(?:\s|\-?)[A-ZÄÀÁÇÈÉëÌÍÖÒÓ]))?(?:(?:\s|\-?)(?:[S][t]\a?\.\s)?[A-ZÄÀÁÇÈÉëÌÍÖÒÓ][a-zäàáçèéëìíöòó',]+)+\s\([^$><";,]+?(?:[;,]\s[^;),]+?)?[;,]\s\d+[^)]+?\)|\s\([^$><";,]+?(?:[;,]\s[^;),><"]+?)?[;,]\s\d+[^)]+?\))/g) || ''
            for activity in groupActivities
              sourceDay = dayNumber
              sourceTime = trim(group[0])
              sourceIndex = group[1].match(/\n(\d+)\)\s.*\n/)[1] || null
              sourceGroup = group[1].match(/\n\d+\)\s(.*)\n/)[1] || null
              if isArray( activity.match(/(.*?)\s\(/) ) then name = activity.match(/(.*?)\s\(/)[1] else null
              if isArray( activity.match(/\((.*?)[,;]\s(?=\d+).*?\)/) ) then streetAddress = activity.match(/\((.*?)[,;]\s(?=\d+).*?\)/)[1] else null
              if isArray( activity.match(/\(.*?[,;]\s((?=\d+).*?)(?:[;,]|\))/) ) then phone = activity.match(/\(.*?[,;]\s((?=\d+).*?)(?:[;,]|\))/)[1] else null
              website = ''
              pageList.push { 
                sourceDay: sourceDay
                sourceTime: sourceTime
                sourceIndex: sourceIndex
                sourceGroup: sourceGroup
                name: name
                streetAddress: streetAddress
                locality: locationBest
                phone: phone
                website: website
              }
              sourceDay = null
              sourceTime = null
              sourceIndex = null
              sourceGroup = null
              name = null
              streetAddress = null
              locality = null
              phone = null
              website = null

    if focusArea.indexOf("IF YOU GO") != -1 || focusArea.indexOf("THE BASICS") != -1
      endDetail = focusArea.split(/\nTHE\sBASICS\n|\nIF\sYOU\sGO\n/i)[1]
      endActivities = endDetail.match(/(((?:[S][t]\a?\.\s)?[A-ZÄÀÁÇÈÉëÌÍÖÒÓ][a-zäàáçèéëìíöòó,']+(?=(?:\s|\-?)[A-ZÄÀÁÇÈÉëÌÍÖÒÓ]))?(?:(?:\s|\-?)(?:[S][t]\a?\.\s)?[A-ZÄÀÁÇÈÉëÌÍÖÒÓ][a-zäàáçèéëìíöòó',]+)+\s\([^$><";,]+?(?:[;,]\s[^;),]+?)?[;,]\s\d+[^)]+?\)|\s\([^$><";,]+?(?:[;,]\s[^;),><"]+?)?[;,]\s\d+[^)]+?\))/g) || ''
      for activity in endActivities
        if isArray( activity.match(/(.*?)\s\(/) ) then name = activity.match(/(.*?)\s\(/)[1] else null
        if isArray( activity.match(/\((.*?)[,;]\s(?=\d+).*?\)/) ) then streetAddress = activity.match(/\((.*?)[,;]\s(?=\d+).*?\)/)[1] else null
        if isArray( activity.match(/\(.*?[,;]\s((?=\d+).*?)(?:[;,]|\))/) ) then phone = activity.match(/\(.*?[,;]\s((?=\d+).*?)(?:[;,]|\))/)[1] else null
        website = ''
        pageList.push { 
          sourceGroup: "Destination Details" 
          name: name
          streetAddress: streetAddress
          locality: locationBest
          phone: phone
          website: website
        }
        name = null
        streetAddress = null
        locality = null
        phone = null
        website = null

# ~2010 instance without detail box
if path.indexOf("/travel/") != -1 && path.indexOf("hours.html") != -1

  locationBest = splitBy("h1", splitByOptions)
  # NEEDSFOLLOWUP DATEPUBLISHED

  groupArray = []

  focusArea = textSelector("#article")

  if focusArea && focusArea.length
    days = [] 
    if focusArea.indexOf("Friday") != -1 && focusArea.indexOf("Saturday") != -1 && focusArea.indexOf("Sunday") != -1
    # if focusArea.indexOf(/\nFriday\n/g) != -1 && focusArea.indexOf(/\nSaturday\n/g) != -1 && focusArea.indexOf(/\nSunday\n/g) != -1
    #   if focusArea.indexOf(/\nIF YOU GO\n/gi) != -1 || focusArea.indexOf(/\nTHE BASICS\n/gi) != -1
      console.log "FriSatSun"
      if focusArea.indexOf("IF YOU GO") != -1 || focusArea.indexOf("THE BASICS") != -1
      #   days.push focusArea.split(/\nFriday\n/)[1].split(/\nSaturday\n/)[0]
      #   days.push focusArea.split(/\nSaturday\n/)[1].split(/\nSunday\n/)[0]
      #   days.push focusArea.split(/\nSunday\n/)[1].split(/\nTHE\sBASICS\n|\nIF\sYOU\sGO\n/i)[0]
      # else 
        days.push focusArea 

      console.log days

      dayNumber = 0
      for day in days
        dayNumber = dayNumber + 1
        if day.indexOf(/\n\d?\d?:?\d?\d\s[ap]\.[m]\./g) != -1
          groupTimeArray = day.match(/\n\d?\d?:?\d?\d\s[ap]\.[m]\.|\n[N][o][o][n]/g)
          groupSectionArray = day.split(/\n\d?\d?:?\d?\d\s[ap]\.[m]\.|\n[N][o][o][n]/g)
          groupSectionArray = groupSectionArray.filter( (n) -> n != '' ) 
        if groupTimeArray && groupSectionArray && groupTimeArray.length == groupSectionArray.length
          i = 0
          while i < groupTimeArray.length
            time = trim( groupTimeArray[i] )
            content = groupSectionArray[i]
            groupArray.push [ time, content ]
            i++
          for group in groupArray
            groupActivities = group[1].match(/(((?:[S][t]\a?\.\s)?[A-ZÄÀÁÇÈÉëÌÍÖÒÓ][a-zäàáçèéëìíöòó,']+(?=(?:\s|\-?)[A-ZÄÀÁÇÈÉëÌÍÖÒÓ]))?(?:(?:\s|\-?)(?:[S][t]\a?\.\s)?[A-ZÄÀÁÇÈÉëÌÍÖÒÓ][a-zäàáçèéëìíöòó',]+)+\s\([^$><";,]+?(?:[;,]\s[^;),]+?)?[;,]\s\d+[^)]+?\)|\s\([^$><";,]+?(?:[;,]\s[^;),><"]+?)?[;,]\s\d+[^)]+?\))/g) || ''
            for activity in groupActivities
              sourceDay = dayNumber
              sourceTime = trim(group[0])
              sourceIndex = group[1].match(/\n(\d+)\)\s.*\n/)[1] || null
              sourceGroup = group[1].match(/\n\d+\)\s(.*)\n/)[1] || null
              if isArray( activity.match(/(.*?)\s\(/) ) then name = activity.match(/(.*?)\s\(/)[1] else null
              if isArray( activity.match(/\((.*?)[,;]\s(?=\d+).*?\)/) ) then streetAddress = activity.match(/\((.*?)[,;]\s(?=\d+).*?\)/)[1] else null
              if isArray( activity.match(/\(.*?[,;]\s((?=\d+).*?)(?:[;,]|\))/) ) then phone = activity.match(/\(.*?[,;]\s((?=\d+).*?)(?:[;,]|\))/)[1] else null
              website = ''
              pageList.push { 
                sourceDay: sourceDay
                sourceTime: sourceTime
                sourceIndex: sourceIndex
                sourceGroup: sourceGroup
                name: name
                streetAddress: streetAddress
                locality: locationBest
                phone: phone
                website: website
              }
              sourceDay = null
              sourceTime = null
              sourceIndex = null
              sourceGroup = null
              name = null
              streetAddress = null
              locality = null
              phone = null
              website = null

    if focusArea.indexOf("/\nIF YOU GO\n/gi") != -1 || focusArea.indexOf("/\nTHE BASICS\n/gi") != -1
      endDetail = focusArea.split(/\nTHE BASICS\n|\nIF YOU GO\n/i)[1]
      endActivities = endDetail.match(/(((?:[S][t]\a?\.\s)?[A-ZÄÀÁÇÈÉëÌÍÖÒÓ][a-zäàáçèéëìíöòó,']+(?=(?:\s|\-?)[A-ZÄÀÁÇÈÉëÌÍÖÒÓ]))?(?:(?:\s|\-?)(?:[S][t]\a?\.\s)?[A-ZÄÀÁÇÈÉëÌÍÖÒÓ][a-zäàáçèéëìíöòó',]+)+\s\([^$><";,]+?(?:[;,]\s[^;),]+?)?[;,]\s\d+[^)]+?\)|\s\([^$><";,]+?(?:[;,]\s[^;),><"]+?)?[;,]\s\d+[^)]+?\))/g) || ''
      for activity in endActivities
        if isArray( activity.match(/(.*?)\s\(/) ) then name = activity.match(/(.*?)\s\(/)[1] else null
        if isArray( activity.match(/\((.*?)[,;]\s(?=\d+).*?\)/) ) then streetAddress = activity.match(/\((.*?)[,;]\s(?=\d+).*?\)/)[1] else null
        if isArray( activity.match(/\(.*?[,;]\s((?=\d+).*?)(?:[;,]|\))/) ) then phone = activity.match(/\(.*?[,;]\s((?=\d+).*?)(?:[;,]|\))/)[1] else null
        website = ''
        pageList.push { 
          sourceGroup: "Destination Details" 
          name: name
          streetAddress: streetAddress
          locality: locationBest
          phone: phone
          website: website
        }
        name = null
        streetAddress = null
        locality = null
        phone = null
        website = null

if path.indexOf("things-to-do-in-36-hours") != -1
  # ~2014 instance with detail box

  locationBest = splitBy("h1", splitByOptions)
  console.log locationBest

  detailBox = null
  detailBox = getSubSelector(".story-footer", ".story-info")

  detailBoxItems = detailBox.find("p")
  for item in detailBoxItems
    item = $(item)
    strong = item.find("strong")
    for strongItem in strong
      strongItem = $(strongItem)
      listNumber = item.html().match(/(\d+)\.\s./) || null
      if listNumber && listNumber.length
        listNumber = listNumber[1]
        # what if there are two list numbers at once e.g. http://www.nytimes.com/2014/09/14/travel/things-to-do-in-36-hours-in-cartagena-colombia.html
        name = strongItem.html().replace(/\d+\./, "") || ''
        if item.html().indexOf(",") != -1 && item.html().indexOf(";") != -1
          fullAddress = item.html().split(",")[1].split(";")[0] || ''
        website = item.find("a").attr("href") || ''
        pageList.push( { 
          listNumber: listNumber
          name: name
          fullAddress: fullAddress
          website: website
          sourceNotes: "test"
        } )

window.pageList = pageList

  # if byClass('dateline')
  #   published1 = byClass('dateline').innerHTML
  #   published2 = published1.split(': ')[1]
  #   published = published2
  # else 
  #   published = ''

  # if byClass('story-heading')
  #   locale1 = byClass('story-heading').innerHTML
  # else if byClass('articleHeadline')
  #   locale1 = byClass('articleHeadline').innerHTML
  # else
  #   locale1 = 'NEEDS LOCALE'
  # # locale2 = locale1.split('36 Hours | ')[1]
  # if locale1.indexOf('36 Hours in ') != -1
  #   locale2 = locale1.split('36 Hours in ')[1]
  # else if locale1.indexOf('36 Hours | ') != -1
  #   locale2 = locale1.split('36 Hours | ')[1]
  # else if locale1.indexOf(': ') != -1
  #   locale3 = locale1.split(': ')[0]
  #   locale2 = locale3.split('<nyt_headline version="1.0" type=" ">')[1]
  # else
  #   locale2 = 'NEEDS LOCALE'
  # locale = locale2

  # # BULLSHIT FOR JUST ONE INSTANCE OF ARTICLEBODY
  # if byClassMultiple('articleBody') 
  #   sections1 = byClassMultiple('articleBody')
  # else if byClassMultiple('story-body-text')
  #   sections1 = byClassMultiple('story-body-text')
  # else
  #   sections1 = ''
  # # sections2 = sections1.innerHTML
  # # sections3 = trim sections2

  # sectionIndex = 0
  # sectionsText = ""
  # while sectionIndex < sections1.length
  #   sectionContent = sections1[sectionIndex].innerHTML
  #   sectionsText += " "+sectionContent
  #   sectionIndex++

  # sentences = sectionsText.split('. ')
  # # sectionInfo1 = sectionContent.split('(')[1]
  # # sectionInfo2 = sectionInfo1.split(')')[0]

nameList = []
i = 0
while i < pageList.length
  nameList.push pageList[i].name
  i++
window.nameList = nameList

addressList = []
i = 0
while i < pageList.length
  addressList.push pageList[i].streetAddress
  i++
window.addressList = addressList

phoneList = []
i = 0
while i < pageList.length
  phoneList.push pageList[i].phone
  i++
window.phoneList = phoneList

# highlight = (container, array, color) -> 
#   replacement = $(container).html()
#   for itemName in array
#     newValue = '<span style="background: '+color+'">'+itemName+'</span>'
#     regExFind = new RegExp(itemName, "g")
#     replacement = replacement.replace( regExFind, newValue )
#   $(container).replaceWith(replacement)
# highlight("#area-main", nameList, '#f58793')

# highlight = (container, array, color) -> 
#   for item in array
#     newValue = '<span style="background: '+color+'">'+item+'</span>'
#     regExFind = new RegExp(item, "g")
#     textNodes = $(container).contents().filter -> 
#       @nodeType is 3
#     console.log textNodes.text()
#     # for textNode in textNodes
#     #   original = textNode.text()
#     #   console.log original
#     #   replacement = original.replace(regExFind, newValue)
#     #   textNode.text().replaceWith(replacement)

# highlight( phoneList, '#eee')
# highlight( addressList, '#eee')

# return {
#   name: name
#   fullAddress: fullAddress
#   streetAddress: streetAddress
#   locality: locality
#   region: region
#   postalCode: postalCode
#   country: country
#   phone: phone
#   website: website
#   category: category
#   priceInfo: priceInfo
#   sourceNotes: sourceNotes
#   rating: rating
#   ranking: ranking
#   images: imageList
#   tab_image: photoToUse
#   image_credit: siteName
#   source: siteName
#   source_url: document.URL
#   lat: lat
#   lon: lon
#   has_tab: true
#   parent_day: null
# }
