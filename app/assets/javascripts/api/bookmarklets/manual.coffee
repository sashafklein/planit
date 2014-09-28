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

  # pull_date = today  
  planitTitle = document.createElement( 'div' )
  # TITLE STYLING
  planitTitle.style.borderBottom = "2px solid black"
  planitTitle.style.padding = '0px'
  planitTitle.style.paddingBottom = '5px'
  planitTitle.style.width = '100%'
  planitTitle.style.fontFamily = 'trebuchet ms'
  planitTitle.style.fontSize = '15px'
  planitTitle.style.fontWeight = 'bold'

  planitTitle.innerHTML = 'Planit Clipper'

  planitDiv = document.createElement( 'div' )
  # CONTAINER STYLING
  planitDiv.style.position = "fixed"
  planitDiv.style.right = '80px'
  planitDiv.style.top = '40px'
  planitDiv.style.padding = '20px'
  planitDiv.style.width = '250px'
  planitDiv.style.background = '#fff'
  planitDiv.style.fontFamily = 'trebuchet ms'
  planitDiv.style.fontSize = '11px'
  planitDiv.style.border = "1px solid #ccc"
  planitDiv.style.borderBottom = "2px solid #000"
  planitDiv.style.borderRight = "2px solid #000"
  planitDiv.style.zIndex = '2147483647'

  planitDiv.appendChild( planitTitle )

  planitName = document.createElement( 'input' )
  planitName.style.width = '100%'
  planitName.style.marginTop = '10px'
  planitName.style.background = '#ffe'

  planitDiv.appendChild( planitName )

  planitAddress = document.createElement( 'input' )
  planitAddress.style.width = '90%'
  planitAddress.style.marginTop = '10px'

  planitDiv.appendChild( planitAddress )

  planitNotes = document.createElement( 'input' )
  planitNotes.style.width = '100%'
  planitNotes.style.marginTop = '10px'

  planitDiv.appendChild( planitNotes )

  # planitImage = document.createElement( 'img' )
  # planitImage.style.width = '100%'
  # planitImage.style.width = '150px'
  # planitImage.style.marginTop = '10px'

  # planitDiv.appendChild( planitImage )


  document.body.appendChild( planitDiv )
