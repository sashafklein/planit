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

  name = null
  streetAddress = null
  locality = null
  region = null
  country = null
  postalCode = null
  country = null
  phone = null
  website = null
  category = []
  priceInfo = null
  sourceNotes = null
  ranking = null
  rating = null
  imageList = []
  photoToUse = null
  siteName = null
  lat = null
  lon = null

  photoById = (id) -> 
    element = document.getElementById(id)
    if element then element.src else ''

  byId = (id) -> document.getElementById(id)

  byClass = (className) ->
    els = document.getElementsByClassName(className)
    if els.length then els[0] else ''

  photoByClass = (className) -> byClass(className).src

  deTag = (html) -> 
    if html && html.length
      html.replace(/<(?:.|\n)*?>/gm, '')

  trim = (html) -> 
    if html && html.length
      #NEEDSFOLLOWUP -- NEED TO ELIMINATE INTERNAL SPACES
      # while html:contains("  ")
      #   html.replace("  ", " ")
      html.replace(/^\s+|\s+$/g, '')

  deBreak = (html) -> 
    if html && html.length
      html.replace(/(\r\n|\n|\r)/gm, '')

  cleanOrNull = (html) -> 
    if html && html.length
      deTag(html)
    else null

  bySelector = (selector) -> 
    item = $(selector)
    if item && item.length
      itemElement = item.html()
      itemElement.replace("&amp;", "&")
    else null

  ifSelector = (selector) -> 
    item = $(selector)
    if item && item.length
      item
    else null

  chooseOption = (selectorAndFunctionArray) ->
    for selectorAndFunction in selectorAndFunctionArray
      selector = selectorAndFunction[0]
      callback = selectorAndFunction[1]
      if $(selector) && $(selector).length
        return callback(selector)

  path = window.location.href

  div = -> $('#planit-bookmarklet')

  acceptedPath = (pathName) -> true

  timeoutDiv = ->
    setTimeout( 
      -> div().fadeOut('slow'),
      3000
    )

  getPageData = () -> 'SPECIFIC_FILE'

  getDivTemplate = (message, button=false, callback) ->
    post_path = "HOSTNAME/api/v1/bookmarklets/base"
    $.get(post_path, callback)

  showDiv = (message, button=false) ->
    if div().length
      getDivTemplate message, button, (response) ->
        div().replaceWith(response)
        div().fadeIn('slow')
        setTriggers()
    else
      getDivTemplate message, button, (response) ->
        $('body').prepend(response)
        div().fadeIn('slow')
        setTriggers()

    timeoutDiv() unless button

  fullAddress = (pageData) ->
    full = []
    if pageData['street_address'] then full.push pageData['street_address']
    if pageData['locality'] then full.push pageData['locality']
    if pageData['region'] then full.push pageData['region']
    if pageData['postalCode'] then full.push pageData['postalCode']
    if pageData['country'] then full.push pageData['country']
    return full.join(", ")

  additionalInfo = (pageData) ->
    toAdd = []
    if pageData['lat'] then toAdd.push "lat: " + pageData['lat']
    if pageData['lon'] then toAdd.push "lon: " + pageData['lon']
    if pageData['phone'] then toAdd.push "phone: " + pageData['phone']
    if pageData['website'] then toAdd.push "website: " + pageData['website']
    if pageData['priceInfo'] then toAdd.push "priceInfo: " + pageData['priceInfo']
    if pageData['sourceNotes'] then toAdd.push "sourceNotes: " + pageData['sourceNotes']
    if pageData['rating'] then toAdd.push "rating: " + pageData['rating']
    if pageData['ranking'] then toAdd.push "ranking: " + pageData['ranking']
    if pageData['category'] then toAdd.push "category: " + pageData['category'][0] # NEEDSFOLLOWUP
    return toAdd.join(", ")

  # replaceAlertValues = (dataSource, target) ->
  #   if dataSource && dataSource.length

  #   replaceAlertValues("pageData['images'][0].url", )

  setAlertValues = (pageData) ->
    flash = $("#saved-message-flash")
    if pageData['images'] && pageData['images'].length
      if pageData['images'][0].url && pageData['images'][0].url.length
        flash.find('#planit-saved-demo').find('img').attr('src', pageData['images'][0].url || '')
    if pageData['name'] && pageData['name'].length
      flash.find('#planit-name').attr('value', pageData['name'] || '')
    if fullAddress(pageData) && fullAddress(pageData).length
      flash.find('#planit-address').attr('value', fullAddress(pageData))
    if additionalInfo(pageData) && additionalInfo(pageData).length
      flash.find('#saved-add-note').attr('value', additionalInfo(pageData))

  setTriggers = () ->
    $('#planit-click-save').click (e) ->
      pageData = getPageData()
      if pageData['name'] && pageData['name'].length && fullAddress(pageData) && fullAddress(pageData).length
        setAlertValues(pageData)
        e.preventDefault()
        $.ajax
          url: "HOSTNAME/api/v1/bookmarklets/save_item" 
          type: 'POST'
          dataType: 'json'
          data: pageData
          success: -> 
            $('#saved-message-flash').fadeIn('slow')
          failure: -> 
      else alert("Load Manual -- both Name and Address not present")

    $('#planit-click-cancel').click (e) -> 
      e.preventDefault()
      div().fadeOut('slow')


  #### BASE BEHAVIOR
  if acceptedPath(path)
    showDiv "Do you want to submit this item to Planit?", true
  else
    # This isn't happening yet