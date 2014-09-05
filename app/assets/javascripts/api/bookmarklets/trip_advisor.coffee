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
    alert "You must be on a Trip Advisor to use this tool."
  else
    if confirm("Do you want to submit item to Planit?")
      try
        $.post "HOSTNAME/api/v1/items",
          question:
            link: getData()
            user_id: "USER_ID"

        alert "Item submitted to Planit!"
      catch
        # Post to an error path?
        alert "Something went wrong! Please let us know."