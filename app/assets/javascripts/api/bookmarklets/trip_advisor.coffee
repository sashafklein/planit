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

    a.documentElement.childNodes[0].appendChild c
  return
) window, document, "1.3.2", ($, L) ->

  path = window.location.href
  if path.indexOf("tripadvisor.com") is -1
    alert "You must be on Trip Advisor to use this tool."
  else
    # if confirm("Do you want to submit item to Planit?")
    try
      photoById = (id) -> 
        element = document.getElementById(id)
        if element then element.src else ''

      byId = (id) -> document.getElementById(id)

      byClass = (className) ->
        els = document.getElementsByClassName(className)
        if els.length then els[0] else ''

      photoByClass = (className) -> byClass(className).src

      deTag = (html) -> html.replace(/<(?:.|\n)*?>/gm, '')

      trim = (html) -> html.replace(/^\s+|\s+$/g, '')

      cleanOrNull = (html) -> if html then deTag(html) else null

      photo1 = photoById("HERO_PHOTO")
      photo2 = photoByClass("photo_image")
      photo3 = photoByClass("heroPhotoImg")

      name_start = deTag byId("HEADING").innerHTML
      name = if name_start then trim(name_start) else ''

      latLonImage = byId("STATIC_MAP")?.getElementsByTagName('img')?[0] || null
      latLon = if latLonImage then latLonImage.src.split("center=")[1].split('&zoom')[0] else ''
      lat = if latLon then latLon.split(',')[0] else ''
      lon = if latLon then latLon.split(',')[1] else ''
      # May not return latLon now b/c of error "nil" exception

      address = byClass("street-address").innerHTML

      locality = cleanOrNull(byClass('locality').innerHTML)

      city = if locality then locality.split(', ')[0] else ''
      state_start = if locality then locality.split(', ')[1] else ''
      state = if state_start then state_start.split(' ')[0] else ''
      postal_code = if locality then locality.split(' ')[3] else ''
      county = if city && state then '' else locality

      country = cleanOrNull(byClass('country-name').innerHTML)

      phone_start = cleanOrNull(byClass('fl phoneNumber').innerHTML)
      phone = if phone_start then phone_start else ''

      photoToUse = photo1 || photo2 || photo3

      alert [
        "          -\n"
        "name: #{name}\n"
        "street_address: #{address}\n"
        "city: #{city}\n"
        "county: #{county}\n"
        "state: #{state}\n"
        "postal_code: #{postal_code}\n"
        "country: #{country}\n"
        "phone: #{phone}\n"
        "tab_image: #{photoToUse}\n"
        "has_tab: true\n"
        "image_credit: TripAdvisor\n"
        "source: TripAdvisor\n"
        "source_url: #{document.URL}\n"
        "lat: #{lat}\n"
        "lon: #{lon}\n"
        "parent_day: \n"
      ].join('            ')

      $.post "HOSTNAME/api/v1/items",
        question:
          data: 
            name: name
            street_address: address
            locality: locality
            country: country
            phone: phone
            tab_image: photoToUse
            has_tab: true
            image_credit: 'TripAdvisor'
            source: 'TripAdvisor'
            source_url: document.URL
            lat: lat
            lon: lon
            parent_day: null
          user_id: "USER_ID"

      # alert "Item submitted to Planit!"
    catch err
      # Post to an error path?
      alert "Something went wrong! Please let us know. Error: #{err}"