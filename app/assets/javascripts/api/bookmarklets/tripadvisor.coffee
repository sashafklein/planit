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

photo1 = photoById('HERO_PHOTO')
photo2 = photoByClass('photo_image')
photo3 = photoByClass('heroPhotoImg')

name_start = deTag byId('HEADING').innerHTML
name = if name_start then trim(name_start) else ''

latLonImage = byId('STATIC_MAP')?.getElementsByTagName('img')?[0] || null
latLon = if latLonImage then latLonImage.src.split('center=')[1].split('&zoom')[0] else ''
lat = if latLon then latLon.split(',')[0] else ''
lon = if latLon then latLon.split(',')[1] else ''
# May not return latLon now b/c of error 'nil' exception

address = byClass('street-address').innerHTML

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

return {
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
}