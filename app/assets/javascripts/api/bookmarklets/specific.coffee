# setTriggers = () ->
#   $('#planit-click-save').click (e) ->
#     e.preventDefault()
#     if pageData['name'] && pageData['name'].length
#       postData()
#     else alert("Load Manual -- both Name and Address not present")

#   $('#planit-click-cancel').click (e) -> 
#     e.preventDefault()
#     div().fadeOut('slow')

# pageData = {
#   name: null
#   streetAddress: null
#   locality: null
#   region: null
#   country: null
#   postalCode: null
#   country: null
#   phone: null
#   website: null
#   category: []
#   priceInfo: null
#   sourceNotes: null
#   ranking: null
#   rating: null
#   imageList: []
#   photoToUse: null
#   siteName: null
#   lat: null
#   lon: null
#   has_tab: true
#   parent_day: null
#   sourceUrl: document.URL
# }

# name = (nameVal) -> pageData['name'] = nameVal
# street_address = (street_addressVal) -> pageData['streetAddress'] = streetAddressVal
# locality = (localityVal) -> pageData['locality'] = localityVal
# region = (regionVal) -> pageData['region'] = regionVal
# postalCode = (postalCodeVal) -> pageData['postalCode'] = postalCodeVal
# country = (countryVal) -> pageData['country'] = countryVal
# phone = (phoneVal) -> pageData['phone'] = phoneVal
# website = (websiteVal) -> pageData['website'] = websiteVal
# category = (categoryVal) -> pageData['category'] = categoryVal
# priceInfo = (priceInfoVal) -> pageData['priceInfo'] = priceInfoVal
# sourceNotes = (sourceNotesVal) -> pageData['sourceNotes'] = sourceNotesVal
# rating = (ratingVal) -> pageData['rating'] = ratingVal
# ranking = (rankingVal) -> pageData['ranking'] = rankingVal
# images = (imagesVal) -> pageData['images'] = imagesVal
# tab_image = (tab_imageVal) -> pageData['photoToUse'] = photoToUseVal
# image_credit = (image_creditVal) -> pageData['siteName'] = siteNameVal
# source = (sourceVal) -> pageData['siteName'] = siteNameVal
# lat = (latVal) -> pageData['lat'] = latVal
# lon = (lonVal) -> pageData['lon'] = lonVal

((e, a, g, h, f, c, b, d) ->
  if not (f = e.jQuery) or g > f.fn.jquery or h(f)
    c = a.createElement("script")
    c.type = "text/javascript"
    c.src = "http://ajax.googleapis.com/ajax/libs/jquery/" + g + "/jquery.min.js"
    c.onload = c.onreadystatechange = ->
      if not b and (not (d = @readyState) or d is "loaded" or d is "complete")
        h (f = e.jQuery).noConflict(1), b = 1
        f(c).remove()
      return

    document.body.appendChild( c )
  return
) window, document, "1.3.2", ($, L) ->

  pageData = {}
  name = null
  fullAddress = null
  streetAddress = null
  locality = null
  region = null
  country = null
  postalCode = null
  phone = null
  website = null
  category = []
  priceInfo = null
  sourceNotes = null
  ranking = null
  rating = null
  imageList = []
  images = []
  photoToUse = null
  siteName = null
  lat = null
  lon = null

  setBack = (selector) ->
    if $(selector) && $(selector).length
      $(selector).css("z-index", "1")

  # DOM MANIPULATION

  byId = (id) -> document.getElementById(id)

  byClass = (className) ->
    els = document.getElementsByClassName(className)
    if els.length then els[0] else ''

  deTag = (html) -> 
    if html && html.length
      html.replace(/<(?:.|\n)*?>/gm, '')

  trim = (html) -> 
    if html && html.length
      html = html.replace(/(\r\n|\n|\r)/gm, '')
      html = html.replace(/( {2,})/gm, ' ')
      html = html.replace(/^\s+|\s+$/g, '')
      html = html.replace(/\s+/g, ' ')
      html = html.replace(/(\t)/gm, '')
      html = html.replace(/&amp;/g, "&")
      html = html.replace(/&nbsp;/g, ' ')
      html = unescape(html)

  bySelector = (selector) -> 
    item = $(selector)
    if item && item.length
      trim( deTag ( item.html() ) )
    else null

  isArray = (tester) ->
    if tester && tester.length
      return true
    else false

  textSelector = (selector) -> 
    if $(selector) && $(selector).length
      text = $(selector).html()
      text = text.replace(/\<\/*[p]\>/g, "\n")
      text = text.replace(/\<\/*[br]\>/g, "\n")
      text = text.replace(/\&[l][t]\;(?:.|\n)*?\&[g][t]\;/gm, '')
      deTag( text )
    else null
    # for selector in selectorArray
    #     if $(selector) && $(selector).length
    #       text = $(selector).html()
    #       text = text.replace(/\<\/*[p]\>/g, "\n")
    #       text = text.replace(/\<\/*[br]\>/g, "\n")
    #       deTag( text )
    #     else null

  cleanSubSelector = (selector, subSelector) -> 
    item = $(selector)
    subItem = $(subSelector)
    if item && item.length && subItem && subItem.length
      if item.html().indexOf(subSelector) != "-1"
        trim( deTag( item.find(subSelector).html() ) )
    else null

  getSubSelector = (selector, subSelector) -> 
    item = $(selector)
    subItem = $(subSelector)
    if item && item.length && subItem && subItem.length
      item.find(subSelector)
    else null

  cleanDetailBox = (container, removeItemsArray) ->
    console.log "above cleanDetailBox"
    # for box in containerArray
    #   if $(box) && $(box).length
    #     cleanerBox = $(box).html().replace("&amp;", "&").replace(/&nbsp;/g, ' ')
    cleanerBox = $(container).html().replace("&amp;", "&").replace(/&nbsp;/g, ' ')
    for removeItem in removeItemsArray
      boxInLoop = cleanerBox
      cleanerBox = boxInLoop.replace(removeItem, "")
    return trim( deTag( cleanerBox ) )
  
  parseDetail = (detailHTML) ->
    console.log "NEED TO BUILD PARSE"
    # pop known
    # split unknown
    # detag
    # trim
    # analyze
    # reassemble
    # parseDetailBox = (detailBoxString) ->

  getWebsite = (linkText, container) ->
    if $(container) && $(container).length
      if $(container).find("a:contains('#{linkText}')") && $(container).find("a:contains('#{linkText}')").length
         website = $(container).find("a:contains('#{linkText}')").attr('href')

  getGalleryImages = (containerArray) ->
    console.log "above getImages in containerArray"
    imageList = []
    for selector in containerArray
      if $(selector) && $(selector).length
        if $(selector).html().indexOf('img') != "-1"
          imageArray = $(selector).find("img")
          i = 0
          console.log "above getImages while in #{selector}"
          while i < imageArray.length
            console.log "in while images"
            imageList.push( { url: imageArray[i].src, source: document.URL, credit: siteName } )
            i++

  splitBy = (selector, splitByArray) ->
    if $(selector) && $(selector).length
      for splitBy in splitByArray
        if $(selector).html().indexOf(splitBy[0]) != -1
          return $(selector).html().split(splitBy[0])[splitBy[1]]

  chooseOption = (selectorAndFunctionArray) ->
    console.log "success above selectorAndFunctionArray #{selectorAndFunctionArray}"
    for selectorAndFunction in selectorAndFunctionArray
      selector = selectorAndFunction[0]
      callback = selectorAndFunction[1]
      if $(selector) && $(selector).length
        return callback(selector)

  replaceText = (search, replace) ->
    console.log "in replaceText"
    $("*").each ->
      console.log replace
      if $(this).children().length is 0
        $(this).text $(this).text().replace(search, replace)
      return

  # DIV STRUCTURE

  div = -> $('#planit-bookmarklet')

  acceptedPath = () -> true

  timeoutDiv = ->
    setTimeout( 
      -> hideAll(),
      3000
    )

  setAttr = (attr, value) -> pageData[attr] = value

  getPageData = () -> 'SPECIFIC_FILE'

  compileAddress = (pageData) ->
    fullAdd = []
    if pageData['fullAddress'] then return pageData['fullAddress']
    if pageData['streetAddress'] then fullAdd.push pageData['streetAddress']
    if pageData['locality'] then fullAdd.push pageData['locality']
    if pageData['region'] then fullAdd.push pageData['region']
    if pageData['postalCode'] then fullAdd.push pageData['postalCode']
    if pageData['country'] then fullAdd.push pageData['country']
    return fullAdd.join(", ")

  compileCategories = (pageData) ->
    fullCat = []
    if pageData['category'] && pageData['category'].length > 1
      for cat in pageData['category']
        fullCat.push cat
      return fullCat.join(", ")
    else
      return pageData['category']

  setAlertValue = (dataElement, successPanel, pageData) ->
    dataElementId = "#planit-" + dataElement
    if pageData[dataElement] && pageData[dataElement].length
      successPanel.find(dataElementId).attr('value', "#{pageData[dataElement]}" || '')

  setAlertValues = (pageData) ->
    # successPanel = $("#test-environment")
    # imageCount = 0
    # if pageData['images'] && pageData['images'].length
    #   imageCount = pageData['images'].length
    #   if pageData['images'][0].url && pageData['images'][0].url.length
    #     successPanel.find('#planit-saved-demo').find('img').attr('src', pageData['images'][0].url || '')
    # if compileAddress(pageData) && compileAddress(pageData).length
    #   successPanel.find('#planit-fullAddress').attr('value', "#{compileAddress(pageData)}")
    # if compileCategories(pageData) && compileCategories(pageData).length
    #   successPanel.find('#planit-category').attr('value', "#{compileCategories(pageData)}")
    # setAlertValue('name',successPanel,pageData)
    # setAlertValue('streetAddress',successPanel,pageData)
    # setAlertValue('locality',successPanel,pageData)
    # setAlertValue('region',successPanel,pageData)
    # setAlertValue('postalCode',successPanel,pageData)
    # setAlertValue('country',successPanel,pageData)
    # setAlertValue('phone',successPanel,pageData)
    # setAlertValue('website',successPanel,pageData)
    # setAlertValue('sourceNotes',successPanel,pageData)
    # setAlertValue('priceInfo',successPanel,pageData)
    # setAlertValue('rating',successPanel,pageData)
    # setAlertValue('ranking',successPanel,pageData)
    # setAlertValue('lat',successPanel,pageData)
    # setAlertValue('lon',successPanel,pageData)
    # successPanel.find('#planit-imageCount').html("#{imageCount} images")

  dataSufficient = -> true
    # pageData && pageData.length && pageData['name'] && ((pageData['lat'] && pageData['lon']) || pageData['locality'])
  checkServer = () -> false
    # this would check if our server received
  postData = () ->
    setAlertValues(pageData)
    $.ajax
      url: "HOSTNAME/api/v1/bookmarklets/save_item" 
      type: 'POST'
      dataType: 'json'
      data: pageData
      success: -> showSuccess() #show 
      failure: -> showError()
  dataLoaded = (response) ->
    setTimeout(
      -> dataSufficient(),
      500
    )

  # INJECT BOOKMARKLET

  launchTool = (callback) ->
    unless div().length #unless there's a div already
      getDivTemplate callback #use the callback to generate a div
  
  getDivTemplate = (callback) ->
    $.ajax
      url: "HOSTNAME/api/v1/bookmarklets/base"
      success: (response) -> callback(response) #using callback as function to InsertDiv with the base code
  
  insertDiv = (response) ->
    $('body').prepend(response)
    setTimeout( 
      -> initiateTool(), 
      100
    )

  # DISPLAY/HIDE FUNCTIONS
  initiateTool = ->
    # showLoading() #show life
    if acceptedPath()
      pageData = getPageData()
      window.pageData = pageData
      if dataLoaded()
        postData() #results in showSuccess
      else
        showManual()
    else
      showError()
  showLoading = -> 
    $('#planit-wrapper').fadeIn('fast')
    $('#planit-loading').fadeIn('fast')
    setTimeout(
      -> if $('#planit-loading').css('display') != 'none' then showError("Woops taking too long... ;-("),
      5000
    )
  showSuccess = -> 
    $('#planit-loading').fadeOut('fast')
    $('#planit-manual').fadeOut('fast')
    $('#planit-success').fadeIn('slow')
    # $('#planit-noteWrap').fadeIn('slow')
  showError = (errorMsg) -> 
    $('#planit-loading').fadeOut('fast')    
    $('#planit-success').fadeOut('fast')    
    # $('#planit-noteWrap').fadeOut('fast')    
    $('#planit-error').fadeIn('slow')
    $('#planit-error').html(errorMsg)    
    setTimeout(
      -> hideAll(),
      5000
    )
  showManual = ->
    $('#planit-wrapper').fadeOut('fast')    
    $('#planit-manual').slideDown('fast')
  hideAll = ->
    $('#planit-wrapper').fadeOut('fast')
    $('#planit-manual').fadeOut('fast')

  # INITIAL BEHAVIOR
  launchTool(insertDiv)
  