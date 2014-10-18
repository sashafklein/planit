not (a, b, c) ->
  d = a[c.k] =
    w: a
    d: b
    a: c
    s: {}
    f: ->
      callback: []
      sha: (a) ->
        b = (a) ->
          b = Array(a.length >> 2)
          c = 0

          while c < b.length
            b[c] = 0
            c++
          c = 0
          while c < 8 * a.length
            b[c >> 5] |= (255 & a.charCodeAt(c / 8)) << 24 - c % 32
            c += 8
          b
        c = (a) ->
          b = ""
          c = 0

          while c < 32 * a.length
            b += String.fromCharCode(a[c >> 5] >>> 24 - c % 32 & 255)
            c += 8
          b
        d = (a, b) ->
          c = (65535 & a) + (65535 & b)
          d = (a >> 16) + (b >> 16) + (c >> 16)
          d << 16 | 65535 & c
        e = (a, b) ->
          a << b | a >>> 32 - b
        f = (a, b) ->
          a[b >> 5] |= 128 << 24 - b % 32
          a[(b + 64 >> 9 << 4) + 15] = b

          c = Array(80)
          f = 1732584193
          i = -271733879
          j = -1732584194
          k = 271733878
          l = -1009589776
          m = 0

          while m < a.length
            n = f
            o = i
            p = j
            q = k
            r = l
            s = 0

            while s < 80
              c[s] = (if s < 16 then a[m + s] else e(c[s - 3] ^ c[s - 8] ^ c[s - 14] ^ c[s - 16], 1))
              t = d(d(e(f, 5), g(s, i, j, k)), d(d(l, c[s]), h(s)))
              l = k
              k = j
              j = e(i, 30)
              i = f
              f = t
              s++
            f = d(f, n)
            i = d(i, o)
            j = d(j, p)
            k = d(k, q)
            l = d(l, r)
            m += 16
          Array f, i, j, k, l
        g = (a, b, c, d) ->
          (if a < 20 then b & c | ~b & d else (if a < 40 then b ^ c ^ d else (if a < 60 then b & c | b & d | c & d else b ^ c ^ d)))
        h = (a) ->
          (if a < 20 then 1518500249 else (if a < 40 then 1859775393 else (if a < 60 then -1894007588 else -899497514)))
        i = (a) ->
          c f(b(a), 8 * a.length)
        j = (a) ->
          b = undefined
          c = "0123456789abcdef"
          d = ""
          e = 0

          while e < a.length
            b = a.charCodeAt(e)
            d = d + c.charAt(b >>> 4 & 15) + c.charAt(15 & b)
            e++
          d
        j i(a)

      get: (a, b) ->
        c = null
        c = (if "undefined" isnt typeof a[b] then a[b] else a.getAttribute(b))

      set: (a, b, c) ->
        (if "string" is typeof a[b] then a[b] = c else a.setAttribute(b, c))
        return

      getEl: (a) ->
        b = null
        b = (if a.target then (if 3 is a.target.nodeType then a.target.parentNode else a.target) else a.srcElement)

      parse: (a, b) ->
        c = undefined
        d = undefined
        e = undefined
        f = undefined
        g = undefined
        h = undefined
        if h = {}
        c = a.split("#")[0].split("?")
        c[1]
          d = c[1].split("&")
          f = 0
          g = d.length

          while f < g
            e = d[f].split("=")
            2 is e.length and b[e[0]] and (h[e[0]] = e[1])
            f += 1
        h

      make: (a) ->
        b = undefined
        c = undefined
        e = not 1
        for b of a
          continue
        e

      kill: (a) ->
        "string" is typeof a and (a = d.d.getElementById(a))
        a and a.parentNode and a.parentNode.removeChild(a)

        return

      call: (a, b) ->
        c = undefined
        e = undefined
        f = "?"
        d.v.nextCallback or (d.v.nextCallback = 0)
        c = d.v.nextCallback
        d.v.nextCallback = d.v.nextCallback + 1
        e = d.a.k + ".f.callback[" + c + "]"
        d.f.callback[c] = (a) ->
          b(a, c)
          d.f.kill(e)
          d.v.callbackLoadingCount = d.v.callbackLoadingCount - 1

          return

        a.match(/\?/) and (f = "&")
        d.d.b.appendChild(d.f.make(SCRIPT:
          id: e
          type: "text/javascript"
          charset: "utf-8"
          src: a + f + "callback=" + e
        ))
        d.v.callbackLoadingCount = d.v.callbackLoadingCount + 1
        d.f.debug("Calling: " + a + f + "callback=" + e)

        return

      listen: (a, b, c, e) ->
        (if e then (if "undefined" isnt typeof a.removeEventListener then a.removeEventListener(b, c, not 1) else "undefined" isnt typeof a.detachEvent and a.detachEvent("on" + b, c)) else (if "undefined" isnt typeof d.w.addEventListener then a.addEventListener(b, c, not 1) else "undefined" isnt typeof d.w.attachEvent and a.attachEvent("on" + b, c)))
        return

      debug: (a) ->
        d.w.console and d.w.console.log and d.v.config.debug and d.w.console.log(a)
        return

      getConfig: ->
        a = d.d.getElementsByTagName("SCRIPT")
        b = a.length
        c = 0
        e = 0
        f = d.a.validConfigParam.length
        g = null
        h = ""
        i = (a) ->
          d.w.setTimeout (->
            d.f.kill a
            return
          ), 10
          return

        c = 0
        while c < b
          if a[c].src.match(d.a.me)
            e = 0
            while e < f
              h = d.a.validConfigParam[e]
              g = a[c].getAttribute(h)
              g and (d.v.config[h] = g)
              e += 1
            i a[c]
            break
          c += 1
        return

      getSelection: ->
        ("" + ((if d.w.getSelection then d.w.getSelection() else (if d.d.getSelection then d.d.getSelection() else d.d.selection.createRange().text)))).replace /(^\s+|\s+$)/g, ""

      getWindowHeight: ->
        a = Math.max(Math.max(d.d.b.scrollHeight, d.d.d.scrollHeight), Math.max(d.d.b.offsetHeight, d.d.d.offsetHeight), Math.max(d.d.b.clientHeight, d.d.d.clientHeight))
        a

      getDim: (a) ->
        b = undefined
        c = undefined
        b = 0
        c = 0
        (if "number" is typeof a.naturalHeight then b = a.naturalHeight else "number" is typeof a.height and (b = a.height))
        (if "number" is typeof a.naturalWidth then c = a.naturalWidth else "number" is typeof a.width and (c = a.width))
        d.f.debug("dimensions for " + a.src + " " + b + " " + c)

          h: b
          w: c

      check:
        visibility: (a) ->
          b = undefined
          c = undefined
          e = undefined
          c = a.parentNode
          b = not 0

          while c and "HTML" isnt c.tagName
            if (if c.currentStyle then ("none" is c.currentStyle.display or "hidden" is c.currentStyle.visibility) and (b = not 1) else d.w.getComputedStyle and ("none" is d.w.getComputedStyle(a).getPropertyValue("display") or "hidden" is d.w.getComputedStyle(a).getPropertyValue("visibility")) and (b = not 1))
            b is not 1
              e = a.src + ": is invisible"
              break
            c = c.parentNode
          e and d.f.debug(e)
          b

        noPin: (a) ->
          b = undefined
          c = undefined
          b = not 0
          d.f.get(a, "data-pin-nopin") and (b = not 1
          c = a.src + ": data-pin-nopin=true"
          )
          d.f.get(a, "nopin") and (b = not 1
          c = a.src + ": nopin=nopin"
          d.f.log("image_with_inline_nopin", a.src)
          )
          c and d.f.debug(c)
          b

        size: (a) ->
          b = undefined
          c = undefined
          e = undefined
          b = not 1
          e = d.f.getDim(a)
          (if e.h > d.a.imgLimitFloor and e.w > d.a.imgLimitFloor then (if e.h > d.a.imgLimitMin or e.w > d.a.imgLimitMin then (if e.w < e.h * d.a.imgLimitHorz then b = not 0 else c = a.src + " too wide") else c = a.src + " one dimension <= " + d.a.imgLimitMin) else c = a.src + " one dimension <= " + d.a.imgLimitFloor)
          c and d.f.debug(c)
          b

        dupe: (a) ->
          b = a
          "object" is typeof a and (b = a.src)
          c = not 0
          (if d.v.src[b] then (d.f.debug(b + ": is a duplicate")
          c = not 1
          ) else d.v.src[b] = not 0)
          c

        source: (a, b) ->
          c = undefined
          e = undefined
          f = undefined
          c = not 1
          f = (if "string" is typeof a then a else a.src or a.href)
          f and f.match(/^http/) and ((if b then (e = f.split("#")[0].split("?")[0].split(".").pop()
          d.a.validImageFileType[e] and (c = not 0)
          ) else c = not 0))
          c is not 0 and d.f.debug("Found high-quality image link: " + f)
          c

        domain: (a) ->
          b = undefined
          c = undefined
          e = undefined
          f = undefined
          g = undefined
          if g = a
          "object" is typeof a and (g = a.src)
          f = g.split("/")[2]
          e = not 0
          "undefined" is typeof d.v.srcDomain[f]
            d.f.debug "checking hashlist against " + f
            c = d.f.sha(f)
            b = 0
            h = d.a.hashList.length

            while b < h
              if c.match(d.a.hashList[b])
                d.f.debug("found a blacklisted domain: " + f)
                d.f.log("domain_blacklisted")
                e = not 1

                break
              b += 1
            d.v.srcDomain[f] = bad: e
          else
            e = d.v.srcDomain[f].bad
          e

      tag:
        img: (a) ->
          b = undefined
          c = undefined
          b = not 0
          for c of d.f.check
            continue
          b

        iframe: (a) ->
          b = undefined
          c = undefined
          if a.src.match(d.a.pattern.youtube.iframe)
            c = a.src.split("#")[0].split("?")[0].split("/")[4]
            c and (d.f.debug("found a YouTube player: " + a.src)
            b =
              media: "http://i.ytimg.com/vi/" + c + "/hqdefault.jpg"
              set:
                url: "http://www.youtube.com/watch?v=" + c
                isVideo: not 0
                attrib: "youtube"

            d.f.loadImg(b)
            )
          a.src.match(d.a.pattern.vimeo.iframe) and (c = (c) ->
            c.thumbnail_url and (d.f.debug("got a Vimeo API reply for iframe: " + a.src)
            b =
              media: c.thumbnail_url.split("_")[0] + ".jpg"
              set:
                url: "https://vimeo.com/" + c.video_id
                description: c.title
                isVideo: not 0
                attrib: "vimeo"

            d.f.loadImg(b)
            )
            return

          b = "https://vimeo.com/api/oembed.json?url=" + encodeURIComponent(a.src)
          d.f.call(b, c)
          )
          return

        a: (a) ->
          b = undefined
          c = undefined
          e = undefined
          f = undefined
          c = d.f.get(a, "data-pin-href")
          c and (e = d.f.parse(c,
            url: not 0
            media: not 0
            description: not 0
          )
          e.media and (d.f.debug("found a Pin It button: " + c)
          b =
            media: decodeURIComponent(e.media)
            set:
              pinItButton: not 0
              url: decodeURIComponent(e.url) or undefined
              description: decodeURIComponent(e.description) or undefined

          f = d.f.get(a, "data-pin-id")
          f and (b.set.dataPinId = f)
          d.f.loadImg(b)
          d.v.hazLoggedPinItButton or (d.v.hazLoggedPinItButton = not 0
          d.f.log("pinit_found")
          )
          )
          )

          return

        link: (a) ->
          b = undefined
          c = undefined
          b = a.rel
          c = a.href
          b and c and (b = b.toLowerCase()
          "canonical" is b and (d.f.debug("found link rel=canonical: " + c)
          d.v.canonicalUrl or (d.v.canonicalUrl = c)
          )
          ("icon" is b or "shortcut-icon" is b or "apple-touch-icon" is b) and (d.v.favicon = c
          d.f.debug("found favicon: " + d.v.favicon)
          )
          )

          return

        meta: (a) ->
          b = undefined
          c = undefined
          e = undefined
          f = undefined
          g = undefined
          b = d.f.get(a, "content")
          c = d.f.get(a, "property")
          f = d.f.get(a, "http-equiv")
          g = d.f.get(a, "content-language")
          e = d.f.get(a, "name")
          f and g and (d.f.debug("got language " + g + " from http-equiv meta")
          d.f.setLang(g)
          )
          b and (e and "pinterest" is e and ("nopin" is b.toLowerCase() and (d.v.data.close = d.v.msg.noPinMeta
          d.f.log("found_nopin_meta")
          d.f.debug("found pinterest nopin meta")
          )
          "nohover" is b.toLowerCase() and (d.v.noHoverMeta = not 0
          d.f.debug("found pinterest nohover meta")
          d.f.log("found_no_hover_meta")
          )
          "pinterest-rich-pin" is e and "false" is b.toLowerCase() and (d.f.debug("found pinterest no-rich-pin meta")
          d.f.log("found_no_rich_pin_meta")
          )
          )
          c and (c.match(/^og:/) and not d.v.meta.og and (d.v.meta.og = {})
          "og:image" is c and (d.v.meta.og.media = b
          d.f.debug("found og:image meta: " + b)
          )
          "og:url" is c and (d.v.meta.og.url = b
          d.f.debug("found og:url meta: " + b)
          )
          "og:description" is c and (d.v.meta.og.description = b
          d.f.debug("found og:description meta: " + b)
          )
          "og:title" is c and (d.v.meta.og.title = b
          d.f.debug("found og:title meta: " + b)
          )
          c.match(/^pin:/) and not d.v.meta.pinterest and (d.v.meta.pinterest = {})
          "pin:media" is c and (d.v.meta.pinterest.media = b
          d.f.debug("found pin:media meta: " + b)
          )
          "pin:url" is c and (d.v.meta.pinterest.url = b
          d.f.debug("found pin:url meta: " + b)
          )
          "pin:description" is c and (d.v.meta.pinterest.description = b
          d.f.debug("found pin:description meta: " + b)
          )
          "pin:id" is c and (d.v.meta.pinterest.id = b
          d.f.debug("found pin:id meta: " + b)
          )
          )
          )

          return

      loadImg: (a) ->
        d.f.debug "loading image " + a.media
        b = undefined
        c = undefined
        d.v.imgLoadingCount = d.v.imgLoadingCount + 1
        b = d.d.createElement("IMG")
        b.onerror = ->
          d.w.clearTimeout(c)
          d.v.imgLoadingCount = d.v.imgLoadingCount - 1

          return

        b.onload = ->
          b = undefined
          e = undefined
          f = undefined
          g = undefined
          h = undefined
          i = undefined
          if d.w.clearTimeout(c)
          f = {}
          d.f.debug(@src + " has loaded")
          d.v.imgLoadingCount = d.v.imgLoadingCount - 1
          f.loaded = not 0
          i = d.f.getDim(this)
          f.height = i.h
          f.width = i.w
          f.media = @src
          a.set
            if "string" is typeof a.set
              f[a.set] = not 0
              d.v.hazSet[a.set] = not 0
            else
              for b of a.set
                f[b] = a.set[b]
                d.v.hazSet[b] = not 0
          a.url and d.v.canonicalUrl and ((if a.url isnt d.v.canonicalUrl then (g = d.v.canonicalUrl.split("/")[2]
          h = a.url.split("/")[2]
          (if g is h then (f.url = a.url
          d.f.debug("Fixing on-domain link " + f.url)
          f.linkOffPage = not 0
          ) else (f.url = a.url
          f.via = d.v.canonicalUrl
          f.linkOffDomain = not 0
          ))
          ) else f.isVideo and (f.isCanonical = not 0))
          d.f.kill(this)
          )
          a.description and (f.description = a.description)
          d.v.found.unshift(f)
          b = 1
          e = d.v.found.length

          while b < e
            if d.v.found[b].media is @src
              (if f.metaOg then (f.description and (d.v.found[b].description = f.description)
              f.url and (d.v.found[b].url = f.url)
              d.v.found[b].isCanonical = not 0
              d.v.found.shift()
              ) else d.v.found.splice(b, 1))
              break
            b += 1
          return

        c = d.w.setTimeout(->
          b = null
          d.v.imgLoadingCount = d.v.imgLoadingCount - 1

          return
        , d.a.maxWait)
        b.src = a.media

        return

      modifiers:
        page: [
          ->
            a = undefined
            b = undefined
            c = undefined
            e = undefined
            f = undefined
            g = undefined
            h = undefined
            if d.d.URL.match(d.a.pattern.amazon.page)
              b = d.d.getElementsByTagName("A")
              c = 0
              e = b.length

              while c < e
                if b[c].href and b[c].href.match("pinterest.com%2Fpin%2Fcreate%2Fbutton%3F")
                  if a = b[c].href.split("&token=")[0].split("pinterest.com%2Fpin%2Fcreate%2Fbutton%3F")
                  a[1]
                    try
                      f = decodeURIComponent(a[1])
                      f and (h = d.f.parse("?" + f,
                        url: not 0
                        media: not 0
                        description: not 0
                      )
                      h.media and h.url and h.description and (h.url = h.url.split("ref%3D")[0]
                      h.description = h.description.split("http")[0]
                      g =
                        media: decodeURIComponent(h.media)
                        set:
                          sourceBump: not 0
                          url: decodeURIComponent(h.url)
                          description: decodeURIComponent(h.description)

                      d.f.loadImg(g)
                      )
                      )
                  break
                c += 1
          ->
            a = undefined
            b = undefined
            c = undefined
            e = undefined
            f = undefined
            g = undefined
            h = undefined
            i = undefined
            j = undefined
            if j = (a) ->
              b = {}
              b.media = "https://i.ytimg.com/vi/" + a.id + "/hqdefault.jpg"
              b.url = "http://www.youtube.com/watch?v=" + a.id
              b.set =
                isVideo: not 0
                attrib: "youtube"
                url: b.url

              a.sourceBump and (b.set.sourceBump = not 0)
              a.sourceOrder and (b.set.sourceOrder = a.sourceOrder)
              d.f.loadImg(b)

              return

            d.d.URL.match(d.a.pattern.youtube.page)
              b = d.d.URL.split("#")[0].split("?v=")
              b[1] and j(
                id: b[1].split("&")[0]
                sourceBump: not 0
              )
              b = d.d.getElementsByClassName("_mfx")
              c = 0
              e = b.length

              while c < e
                if f = b[c].currentStyle or d.w.getComputedStyle(b[c], not 1)
                f and f.backgroundImage and "none" isnt f.backgroundImage and (a = f.backgroundImage.split("&")[0].split("=")
                a[1]
                )
                  g = a[1].split(",")
                  h = g.length - 1
                  i = -1

                  while h > i
                    j
                      id: g[h]
                      sourceOrder: h

                    h -= 1
                  break
                c += 1
          ->
            a = undefined
            b = undefined
            c = undefined
            e = undefined
            f = undefined
            g = undefined
            h = undefined
            i = undefined
            j = undefined
            k = undefined
            if d.d.URL.match(d.a.pattern.google.page) and (d.v.doNotSort = not 0
            a = d.d.getElementById("ires")
            )
              b = a.getElementsByTagName("A")
              c = 0
              e = b.length

              while c < e
                if h = ""
                media = ""
                b[c].href and (g = b[c].href.split("imgrefurl=")
                g[1] and (h = g[1].split("&")[0])
                g = b[c].href.split("imgurl=")
                g[1] and (media = g[1].split("&")[0])
                )
                h and media and (f = b[c].getElementsByTagName("IMG")
                f[0] and (d.f.set(f[0], "data-pin-url", decodeURIComponent(h))
                d.f.set(f[0], "data-pin-media", decodeURIComponent(media))
                )
                )
                i = b[c].parentNode.getElementsByTagName("DIV")
                i[2] and (j = i[2].textContent)
                  try
                    k = JSON.parse(j)
                    "object" is typeof k and (k.s or k.pt) and d.f.set(f[0], "data-pin-description", k.s or k.pt)
                c += 1
          ->
            d.d.URL.match(d.a.pattern.pinterest.page) and window.isMainPinterestSite is not 0 and (d.v.data.close = d.v.msg.installed)
          ->
            d.d.URL.match(d.a.pattern.facebook.page) and (d.v.data.close = d.v.msg.privateDomain.replace(/%privateDomain%/, "Facebook"))
        ]
        img: [
          (a) ->
            b = undefined
            c = undefined
            return b = not 1
            a.media.match(d.a.pattern.amazon.media) and (a.url = d.v.canonicalUrl
            (if a.media.match(/\._/) then (c = a.media.split("._")[0] + ".jpg"
            a.media = c
            a.set =
              sourceBump: not 0
              url: d.v.canonicalUrl

            d.f.loadImg(a)
            b = not 0
            ) else d.f.debug("Found an Amazon image without ._ substring"))
            )
            b
          (a) ->
            b = undefined
            return b = not 1
            a.media.match(d.a.pattern.flickr.media) and (a.getsAttribution = not 0
            a.attrib = "flickr"
            a.url = d.v.canonicalUrl
            b = not 0
            )
            b
          (a) ->
            b = undefined
            c = undefined
            e = undefined
            return b = not 1
            a.media.match(d.a.pattern["500px"].media) and (a.getsAttribution = not 0
            c = a.media.split("#")[0].split("?")[0].split("/")
            e = c.pop()
            e.match(/.jpg/) and (a.media = c.join("/") + "/2048.jpg"
            a.set =
              getsAttribution: not 0
              attrib: "fivehundredpx"
              url: d.v.canonicalUrl

            d.f.loadImg(a)
            b = not 0
            )
            )
            b
          (a) ->
            b = undefined
            c = undefined
            return b = not 1
            a.media.match(d.a.pattern.youtube.media) and (c = a.media.split("/")[4]
            a.media = "https://i.ytimg.com/vi/" + c + "/hqdefault.jpg"
            a.url = d.v.canonicalUrl
            a.url.match(d.a.pattern.youtube.page) and (a.url = "https://www.youtube.com/watch?v=" + c)
            a.set =
              isVideo: not 0
              attrib: "youtube"
              url: a.url

            d.f.loadImg(a)
            b = not 0
            )
            b
          (a) ->
            b = undefined
            c = undefined
            return b = not 1
            a.url or (a.url = d.v.canonicalUrl)
            c = a["data-pin-url"]
            c and (delete a["data-pin-url"]

            a.dataPinUrl = c
            a.url = c
            )
            c = a["data-pin-id"]
            c and (delete a["data-pin-id"]

            a.dataPinId = c
            )
            c = a["data-pin-description"]
            c and (delete a["data-pin-description"]

            a.dataPinDescription = c
            )
            c = a["data-pin-media"]
            c and (delete a["data-pin-media"]

            d.f.check.source(c) and (a.media = c
            a.set =
              dataPinMedia: not 0
              url: a.url

            a.dataPinUrl and (a.set.dataPinUrl = a.dataPinUrl)
            a.dataPinDescription and (a.set.dataPinDescription = a.dataPinDescription)
            a.dataPinId and (a.set.dataPinId = a.dataPinId)
            d.f.loadImg(a)
            b = not 0
            )
            )
            b
          (a, b) ->
            c = undefined
            e = undefined
            return c = not 1
            e = b.parentNode
            "A" is e.tagName and e.href and d.f.check.source(e, not 0) and (a.url or (a.url = d.v.canonicalUrl)
            a.media = e.href
            a.set =
              linkedImg: not 0
              url: a.url

            d.f.loadImg(a)
            c = not 0
            )
            c
        ]
        meta: [
          ->
            a = undefined
            b = undefined
            return a = not 1
            d.v.meta.pinterest and d.v.meta.pinterest.media and d.f.check.source(d.v.meta.pinterest.media) and (b =
              media: d.v.meta.pinterest.media
              set:
                metaPinterest: not 0
                url: d.v.meta.pinterest.url or d.v.canonicalUrl
                description: d.v.meta.pinterest.description or d.d.title or undefined

            d.v.meta.pinterest.id and (b.set.dataPinId = d.v.meta.pinterest.id)
            d.f.loadImg(b)
            a = not 0
            d.f.debug("loading pinterest meta image: " + b.media)
            )
            a
          ->
            a = undefined
            b = undefined
            return d.v.meta.og and d.v.meta.og.media and d.f.check.source(d.v.meta.og.media) and (b =
              media: d.v.meta.og.media
              set:
                metaOg: not 0
                url: d.v.meta.og.url or d.v.canonicalUrl
                description: d.v.meta.og.description or d.v.meta.og.title or d.d.title or undefined

            d.f.loadImg(b)
            a = not 0
            d.f.debug("loading og meta image: " + b.media)
            )
            a = not 1
        ]

      runMods: (a, b, c) ->
        if d.f.modifiers[a]
          e = 0

          while e < d.f.modifiers[a].length and not d.f.modifiers[a][e](b, c)
            e += 1
        return

      getTags: ->
        a = undefined
        b = undefined
        c = undefined
        e = undefined
        f = undefined
        g = undefined
        h = undefined
        i = undefined
        for a of d.a.tag
          continue
        return

      arrange: ->
        a = undefined
        b = undefined
        c = undefined
        e = undefined
        f = undefined
        g = undefined
        a = 0
        b = d.v.found.length

        while a < b
          g = 0
          c = d.v.found[a]
          c.dataPinDescription and (c.description = c.dataPinDescription)
          "number" is typeof c.naturalHeight and c.naturalHeight and (c.height = c.naturalHeight
          delete c.naturalHeight

          )
          "number" is typeof c.naturalWidth and c.naturalWidth and (c.width = c.naturalWidth
          delete c.naturalWidth

          )
          e = parseInt(c.height)
          f = parseInt(c.width)
          f > e and (f = e)
          e > 3 * f and (e = 3 * f)
          g = e * f
          c.isCanonical and (g = 3 * g)
          c.dataPinId and (g = 3 * g)
          (c.pinItButton or c.dataPinMedia or c.dataPinUrl or c.metaPinterest) and (g = 3 * g)
          c.isVideo and (g = 3 * g)
          c.sourceBump and (g = 3 * g)
          f < d.a.thumbCellSize and (g /= 2
          d.v.hazSet.sourceBump and (g /= 10)
          )
          c.metaOg and b > 1 and f < d.a.thumbCellSize and (g /= 100)
          c.sourceOrder and (g -= 100 * c.sourceOrder)
          c.order = g
          a += 1
        if d.v.found.length and not d.v.doNotSort
          h = (a, b) ->
            b.order - a.order

          d.v.found.sort(h)
          g = d.v.found[0].order
          a = 1
          b = d.v.found.length

          while a < b
            if d.v.found[a].order < g / d.v.config.quality
              d.v.found[a].halt = not 0
              break
            a += 1
        return

      makeStyleFrom: (a, b) ->
        c = undefined
        e = undefined
        f = undefined
        g = undefined
        h = ""
        i = b or ""
        for f of a
          a[f].hasOwnProperty and "string" is typeof a[f] and ("maxZ" is a[f] and (a[f] = d.a.maxZ - d.v.maxZ
          d.v.maxZ = d.v.maxZ - 1
          )
          h = h + f + ": " + a[f] + "; "
          )
        i and h and (d.v.css = d.v.css + i + " { " + h + "}\n")
        for f of a
          continue
        return

      presentation: ->
        a = undefined
        b = undefined
        e = undefined
        a = d.f.make(STYLE:
          type: "text/css"
        )
        b = d.a.cdn[d.w.location.protocol] or d.a.cdn["http:"]
        e = d.v.css
        e = e.replace(/#_/g, "#" + c.k + "_")
        e = e.replace(/\._/g, "." + c.k + "_")
        e = e.replace(/;/g, "!important;")
        e = e.replace(/_cdn/g, b)
        e = e.replace(/_pin_it_button/, d.v.msg.button)
        (if a.styleSheet then a.styleSheet.cssText = e else a.appendChild(d.d.createTextNode(e)))
        (if d.d.h then d.d.h.appendChild(a) else d.d.b.appendChild(a))

        return

      structure: ->
        d.w.scroll(0, 0)
        d.s.shim = d.f.make(IFRAME:
          id: d.a.k + "_shim"
        )
        d.d.b.appendChild(d.s.shim)
        d.s.bg = d.f.make(DIV:
          id: d.a.k + "_bg"
        )
        d.d.b.appendChild(d.s.bg)
        d.s.bd = d.f.make(DIV:
          id: d.a.k + "_bd"
        )
        d.s.hd = d.f.make(DIV:
          id: d.a.k + "_hd"
        )
        d.f.debug("config")
        (if d.v.config.noHeader then d.s.hd.className = d.a.k + "_noHeader" else (d.s.bd.appendChild(d.f.make(DIV:
          id: d.a.k + "_spacer"
        ))
        d.s.logo = d.f.make(SPAN:
          id: d.a.k + "_logo"
        )
        d.s.hd.appendChild(d.s.logo)
        d.v.config.noCancel isnt not 0 and (d.s.x = d.f.make(A:
          id: d.a.k + "_x"
          innerHTML: d.v.msg.cancelTitle
        )
        d.s.hd.appendChild(d.s.x)
        )
        ))
        d.s.bd.appendChild(d.s.hd)
        d.s.ct = d.f.make(DIV:
          id: d.a.k + "_ct"
        )
        d.s.bd.appendChild(d.s.ct)
        d.d.b.appendChild(d.s.bd)

        a = d.f.getWindowHeight()
        d.s.bd.offsetHeight < a and (d.s.bd.style.height = a + "px"
        d.s.bg.style.height = a + "px"
        d.s.shim.style.height = a + "px"
        )
        return

      close: ->
        d.f.get(d.d.b, d.a.hazPinningNow) and d.d.b.removeAttribute(d.a.hazPinningNow)
        d.s.bg and (d.f.listen(d.d, "keydown", d.f.keydown, "detach")
        d.f.listen(d.d, "click", d.f.click, "detach")
        d.f.kill(d.s.shim)
        d.f.kill(d.s.bg)
        d.f.kill(d.s.bd)
        d.w.scroll(0, d.v.saveScrollTop)
        d.v.restore and (d.v.restore.style.display = "block")
        d.v.check and d.w.clearTimeout(d.v.check)
        )

        return

      repin: (a) ->
        d.w.open d.a.repin.replace(/%s/, a), "pin" + (new Date).getTime(), d.a.pop
        return

      pin: (a) ->
        b = undefined
        c = undefined
        e = undefined
        f = undefined
        g = undefined
        b = d.v.found[a]
        (if b.dataPinId then (d.f.log("bookmarklet_repin", b.dataPinId)
        d.f.repin(b.dataPinId)
        ) else (c = "url=" + encodeURIComponent(b.url)
        e = "media=" + encodeURIComponent(b.media)
        f = "description=" + encodeURIComponent(d.f.getSelection() or b.description or d.d.title)
        g = d.a.pin + d.v.config.pinMethod + "/?" + c + "&" + e
        d.v.extensionVer and (g = g + "&xv=" + d.v.extensionVer + "&xm=g")
        b.is_video and (g += "&is_video=1")
        g = g + "&" + f
        d.w.open(g, "pin" + (new Date).getTime(), d.a.pop)
        d.f.log("bookmarklet_pin", e)
        ))
        d.f.close()

        return

      click: (a) ->
        b = undefined
        c = undefined
        e = undefined
        b = a or d.w.event
        c = d.f.getEl(b)
        c is d.s.x and (d.f.log("bookmarklet_cancel_click")
        d.f.close()
        )
        c is d.s.logo and d.f.pinFave()
        e = d.f.get(c, "data-pin-index")
        e and d.f.pin(parseInt(e))

        return

      keydown: (a) ->
        b = a or d.w.event
        c = b.keyCode or null
        27 is c and d.f.close()
        return

      scaleThumb: (a, b) ->
        c = undefined
        e = undefined
        e = c = d.a.thumbCellSize
        a and b and (c = Math.floor(d.a.thumbCellSize * (a / b))
        b < d.a.thumbCellSize and (e = b
        c = a
        )
        )

          height: c
          width: e

      thumb: (a, b) ->
        c = undefined
        e = undefined
        f = undefined
        g = undefined
        h = undefined
        i = undefined
        c = d.f.make(SPAN:
          className: d.a.k + "_thumb"
        )
        f
        f = d.f.scaleThumb(a.height, a.width)
        e = d.f.make(IMG:
          src: a.media
          class: d.a.k + "_thumb"
          height: "" + f.height
          width: "" + f.width
          style: "height:" + f.height + "px!important;width:" + f.width + "px!important;"
        )
        c.appendChild(e)
        g = d.f.make(SPAN:
          className: d.a.k + "_pin"
        )
        a.attrib and (h = d.f.make(I:
          className: d.a.k + "_attrib"
        )
        h.style.background = "transparent url(\"" + d.a.cdn[d.w.location.protocol] + "/images/attrib/" + a.attrib + ".png\") 0 0 no-repeat"
        g.appendChild(h)
        )
        a.isVideo or (i = d.f.make(I:
          className: d.a.k + "_dimensions"
          innerHTML: a.width + " x " + a.height
        )
        g.appendChild(i)
        )
        g.setAttribute("data-pin-index", b)
        g.style.height = f.height + "px"
        c.appendChild(g)
        c.scale = f
        c

      pinFave: ->
        a = undefined
        b = undefined
        c = undefined
        e = undefined
        if d.v.hazIOS or d.v.hazIE and not d.v.hazIE_10 and not d.v.hazIE_11
          d.v.data.close = d.v.msg.noPinnablesFound
          d.f.done()
        else
          d.f.log("pinfave_rendered")
          d.s.ct.innerHTML = ""
          a = d.d.URL.split("/")[2]
          b = d.v.favicon or d.w.location.protocol + "//" + a + "/favicon.ico"
          c = d.f.getSelection() or d.d.title or a
          e = d.w.location.protocol
          e.match(/^http/) or (e = "http:")

          f = e + d.a.fave
          f = f + "?url=" + encodeURIComponent(d.d.URL)
          f = f + "&media=" + encodeURIComponent(b)
          f = f + "&method=" + d.v.config.pinMethod
          f = f + "&description=" + encodeURIComponent(c)
          d.s.pinFave = d.f.make(IFRAME:
            id: d.a.k + "_fave"
            src: f
            frameBorder: "0"
            scrolling: "no"
          )
          d.s.pinFave.onload = ->
            d.v.faveReceiver = d.s.pinFave.contentWindow
            d.v.faveReceiver.postMessage("openFave", "*")

            return

          d.s.ct.appendChild(d.s.pinFave)
          d.f.listen(d.w, "message", (a) ->
            "closeFave" is a.data and (d.f.kill(d.s.pinFave)
            d.f.close()
            )
            return
          )
        return

      contents: ->
        a = undefined
        b = undefined
        c = undefined
        e = undefined
        f = undefined
        g = undefined
        if d.v.found.length
          d.f.log("bookmarklet_rendered")
          d.v.nagExtension and (d.f.log("extension_nag_rendered")
          d.f.nagExtension()
          )
          d.f.debug("rendering thumbs")
          e = -1
          f = []
          c = Math.floor(d.s.bd.offsetWidth / (d.a.thumbCellSize + d.a.thumbCellMargin))
          a = 0

          while a < c
            f[a] = 0
            a += 1
          d.s.ct.style.width = c * (d.a.thumbCellSize + d.a.thumbCellMargin) + d.a.thumbCellMargin + "px"
          a = 0
          b = d.v.found.length

          while a < b
            if d.v.found[a].halt
              d.f.debug "hit quality threshold at image " + a + " of " + b + "; halting"
              break
            e = (if Math.min.apply and f.indexOf then f.indexOf(Math.min.apply(window, f)) else (e + 1) % c)
            g = d.f.thumb(d.v.found[a], a)
            g and (g.style.top = f[e] + "px"
            g.style.left = e * (d.a.thumbCellSize + d.a.thumbCellMargin) + "px"
            g.style.width = d.a.thumbCellSize + "px"
            d.s.ct.appendChild(g)
            f[e] = f[e] + g.scale.height + d.a.thumbCellMargin
            )
            a += 1
        else
          d.f.log("no_pinnables_found")
          d.f.pinFave()
        return

      render: ->
        d.f.debug(d.v)
        d.f.set(d.d.b, d.a.hazPinningNow, "true")
        d.f.makeStyleFrom(d.a.presentation)
        d.f.structure()
        d.f.presentation()
        d.f.listen(d.d, "keydown", d.f.keydown)
        d.f.listen(d.d, "click", d.f.click)
        d.f.contents()

        return

      log: (a, b, c) ->
        e = undefined
        f = undefined
        g = undefined
        f = c or d.d.URL
        e = "?type=pinmarklet&pmUrl=" + encodeURIComponent(f) + "&pmReason=" + encodeURIComponent(a)
        b and (e = e + "&pmImg=" + encodeURIComponent(b))
        d.w.setTimeout(->
          g = new Image
          g.src = d.a.log + e

          return
        , d.a.maxWait)

        return

      done: ->
        a = undefined
        b = undefined
        if d.f.debug("done")
        d.v.data.close
          d.v.config.quiet or d.w.alert(d.v.data.close)
          d.f.close()
        else
          d.f.arrange()
          d.v.data.thumb = d.v.found
          a = 0
          b = d.v.data.thumb.length

          while a < b
            d.v.data.thumb[a].src = d.v.data.thumb[a].media
            d.v.data.thumb[a].isVideo and (d.v.data.thumb[a].multimedia = not 0)
            a += 1
          (if d.v.config.share then (d.f.debug("ios share")
          d.d.b.setAttribute(d.v.config.share, JSON.stringify(d.v.data))
          d.v.data.thumb.length or d.v.config.quiet or d.w.alert(d.v.msg.noPinnablesFound)
          ) else (if d.w[d.v.config.render] and "function" is typeof d.w[d.v.config.render] then (d.f.debug("custom render")
          d.w[d.v.config.render](d.v.data)
          ) else (d.f.debug("default render")
          d.f.render()
          )))
        return

      setLang: (a) ->
        a and ((if "object" is typeof d.a.msg[a] then (d.f.debug("Set language " + a)
        d.v.msg = d.a.msg[a]
        ) else (a = a.split("-")[0]
        "object" is typeof d.a.msg[a] and (d.f.debug("Set language " + a)
        d.v.msg = d.a.msg[a]
        )
        )))
        return

      getLang: ->
        a = undefined
        a = d.d.getElementsByTagName("HTML")[0].getAttribute("lang") or ""
        a and (a = a.toLowerCase()
        d.f.setLang(a)
        )

        return

      nagExtension: ->
        if d.a.nagChance > 0 and not Math.floor(Math.random() * d.a.nagChance)
          a = d.w.location.protocol
          a.match(/^http/) or (a = "http:")
          d.v.frameSource = a + d.a.disco + "discover.html"
          d.s.nag = d.f.make(IFRAME:
            id: d.a.k + "_nag"
            src: d.v.frameSource + "?p=" + (new Date).getTime()
            frameBorder: "0"
            scrolling: "none"
          )
          d.s.ct.parentNode.insertBefore(d.s.nag, d.s.ct)
          d.s.nag.onload = ->
            d.v.receiver = d.s.nag.contentWindow
            d.v.receiver.postMessage(d.a.k, d.v.frameSource)

            return

          d.f.listen(d.w, "message", (a) ->
            a.data is d.a.k and d.f.kill(d.s.nag)
            return
          )
        return

      getBrowser: ->
        d.v.nagExtension = not 1
        d.f.get(d.d.b, "data-pinterest-extension-installed") or (/Firefox/.test(d.w.navigator.userAgent) and (d.v.nagExtension = not 0)
        /Safari/.test(d.w.navigator.userAgent) and /Macintosh/.test(d.w.navigator.userAgent) and /(Version\/6|Version\/7)/.test(d.w.navigator.userAgent) and (d.v.nagExtension = not 0)
        /Chrome/.test(d.w.navigator.userAgent) and not /Android/i.test(d.w.navigator.userAgent) and (d.v.nagExtension = not 0)
        )
        (if /msie/i.test(d.w.navigator.userAgent) and not /opera/i.test(d.w.navigator.userAgent) then (d.v.hazIE = not 0
        (/MSIE 10.0/i.test(d.w.navigator.userAgent) or /MSIE 10.0/i.test(d.w.navigator.userAgent)) and (d.v.hazIE_10 = not 0)
        ) else /rv:11/i.test(d.w.navigator.userAgent) and /like Gecko/i.test(d.w.navigator.userAgent) and (d.v.hazIE_11 = not 0))
        null isnt d.w.navigator.userAgent.match(/iP/) and (d.v.hazIOS = not 0)

        return

      init: ->
        a = undefined
        d.d.b = d.d.getElementsByTagName("BODY")[0]
        d.f.get(d.d.b, d.a.hazPinningNow) or (d.d.d = d.d.documentElement
        d.d.h = d.d.getElementsByTagName("HEAD")[0]
        d.v =
          maxZ: 0
          sourceOrder: 0
          canonicalUrl: d.d.URL
          src: {}
          config:
            pinMethod: "bookmarklet"
            quality: d.a.quality

          hazSet: {}
          meta: {}
          imgLoadingCount: 0
          callbackLoadingCount: 0
          srcDomain: {}
          extensionVer: d.f.get(d.d.b, "data-pinterest-extension-installed") or undefined
          msg: d.a.msg.en
          css: ""
          data:
            blacklistedSource: {}
            thumb: []

          found: []

        d.f.getLang()
        d.f.getBrowser()
        d.v.msg.button or (d.v.msg.button = d.a.buttonImage)
        d.f.getConfig()
        (if d.f.check.domain(d.d.URL) then (d.f.getTags()
        d.f.runMods("meta")
        d.f.runMods("page")
        d.v.safety = d.w.setTimeout(->
          d.v.check and d.w.clearTimeout(d.v.check)
          d.f.done()

          return
        , d.a.maxWait)
        (a = ->
          (if d.v.imgLoadingCount > 0 or d.v.callbackLoadingCount > 0 then d.v.check = d.w.setTimeout(a, 100) else (d.v.safety and d.w.clearTimeout(d.v.safety)
          d.f.done()
          ))
          return
        )()
        ) else (d.v.data.close = d.v.msg.noPinDomain
        d.f.done()
        ))
        )

        return
    ()

  d.f.init()
  return
(window, document,
  k: "PIN_" + (new Date).getTime()
  me: /pinmarklet/
  maxZ: 0x8000000000000000
  maxWait: 5e3
  quality: 30
  pop: "status=no,resizable=yes,scrollbars=yes,personalbar=no,directories=no,location=no,toolbar=no,menubar=no,width=750,height=316,left=0,top=0"
  pin: "http://www.pinterest.com/pin/create/"
  repin: "http://www.pinterest.com/pin/%s/repin/x/"
  log: "//log.pinterest.com/"
  disco: "//assets.pinterest.com/ext/"
  fave: "//assets.pinterest.com/ext/pinFave.html"
  nagChance: 1
  hazPinningNow: "data-pinterest-pinmarklet-rendered"
  pattern:
    amazon:
      media: /^https?:\/\/(.*?\.|)images-amazon\.com\/images\//
      page: /^https?:\/\/(.*?\.|)amazon\.com\//

    pinterest:
      page: /^https?:\/\/(.*?\.|)pinterest\.com\//

    facebook:
      page: /^https?:\/\/(.*?\.|)facebook\.com\//

    youtube:
      iframe: /^https?:\/\/www\.youtube\.com\/embed/
      media: /^https?:\/\/(.*?\.|)ytimg\.com\/(vi|li)\//
      page: /^https?:\/\/(.*?\.|)youtube\.com\//

    flickr:
      media: /^https?:\/\/(.*?)\.staticflickr\.com\//
      page: /^https?:\/\/www\.flickr\.com\//

    "500px":
      media: /^https?:\/\/(.*?)\.500px\.org\//

    vimeo:
      iframe: /^https?:\/\/player\.vimeo\.com\/video\//
      media: /^https?:\/\/i\.vimeocdn\.com\/video\//
      page: /^https?:\/\/vimeo\.com\//

    google:
      page: /^https?:\/\/www\.google\.com\/search(.*&tbm=isch.*)/

  validConfigParam: [
    "debug"
    "noCancel"
    "noHeader"
    "pinMethod"
    "render"
    "share"
    "quiet"
    "quality"
  ]
  validImageFileType:
    gif: 1
    jpg: 1
    jpeg: 1
    png: 1
    webp: 1

  imgLimitMin: 119
  imgLimitFloor: 79
  imgLimitHorz: 3
  thumbCellSize: 236
  thumbCellMargin: 14
  tag:
    link: [
      "rel"
      "href"
    ]
    meta: [
      "name"
      "content"
      "property"
      "http-equiv"
      "content-language"
    ]
    a: [
      "data-pin-href"
      "data-pin-id"
    ]
    iframe: ["src"]
    img: [
      "src"
      "title"
      "alt"
      "naturalHeight"
      "naturalWidth"
      "nopin"
      "data-pin-nopin"
      "data-pin-id"
      "data-pin-media"
      "data-pin-url"
      "data-pin-description"
    ]

  buttonImage: "images/bm/button.png"
  cdn:
    "https:": "https://s-passets.pinimg.com"
    "http:": "http://passets.pinterest.com"

  presentation:
    "iframe#shim":
      position: "absolute"
      "z-index": "maxZ"
      top: "0"
      left: "0"
      bottom: "0"
      right: "0"
      height: "100%"
      width: "100%"

    "div#_bg":
      position: "fixed"
      top: "0px"
      left: "0px"
      right: "0px"
      bottom: "0px"
      height: "100%"
      width: "100%"
      background: "#eee"
      "z-index": "maxZ"

    "div#_bd":
      "z-index": "maxZ"
      "text-align": "center"
      position: "absolute"
      width: "100%"
      top: "0"
      left: "0"
      right: "0"
      font: "16px helvetica neue,arial,san-serif"
      "#_spacer":
        display: "block"
        height: "65px"

      "div#_hd":
        "z-index": "maxZ"
        "box-shadow": "rgba(0, 0, 0, 0.219608) 0px 1px 2px 0px"
        position: "fixed"
        "*position": "absolute"
        width: "100%"
        top: "0"
        left: "0"
        right: "0"
        height: "54px"
        display: "block"
        margin: "0"
        background: "#fbf7f7"
        "border-bottom": "1px solid #aaa"
        "&._noHeader":
          height: "1px"
          "background-color": "#f2f2f2"
          "box-shadow": "none"
          border: "none"

        "a#_x":
          display: "inline-block"
          cursor: "pointer"
          color: "#524D4D"
          "text-shadow": "0 1px #fff"
          font: "16px helvetica neue,helvetica,arial,san-serif"
          "letter-spacing": "normal"
          float: "right"
          "line-height": "52px"
          "font-size": "14px"
          "font-weight": "bold"
          "text-align": "center"
          height: "54px"
          width: "100px"
          "border-top": "none"
          "border-bottom": "none"
          "border-right": "none"
          "border-left": "1px solid #aaa"
          "&:hover":
            color: "#524D4D"
            background: "#e1dfdf"
            "text-decoration": "none"

          "&:active":
            color: "#fff"
            background: "#cb2027"
            "text-decoration": "none"
            "text-shadow": "none"

        "#_logo":
          height: "53px"
          width: "100px"
          display: "inline-block"
          "margin-right": "-100px"
          background: "transparent url(_cdn/images/LogoRed.png) 50% 50% no-repeat"
          border: "none"

      "iframe#_fave":
        height: "900px"
        width: "745px"
        padding: "0"
        margin: "0 auto 10px"

      "iframe#_nag":
        height: "300px"
        width: "745px"
        padding: "0"
        margin: "0 auto 10px"

      "div#_ct":
        margin: "0 auto 50px"
        position: "relative"
        "span._thumb":
          background: "#bbb"
          position: "absolute"
          "border-radius": "6px"
          "box-shadow": "rgba(0, 0, 0, 0.219608) 0px 1px 2px 0px"
          overflow: "hidden"
          "font-size": "0"
          "span._pin":
            position: "absolute"
            top: "0"
            left: "0"
            width: "100%"
            cursor: "pointer"
            zoom: "1"
            "background-position": "10px 10px"
            "background-repeat": "no-repeat"
            "-moz-transition-property": "background-color"
            "-moz-transition-duration": ".25s"
            "-webkit-transition-property": "background-color"
            "-webkit-transition-duration": ".25s"
            "transition-property": "background-color"
            "transition-duration": ".25s"
            "img._thumb":
              border: "none"
              margin: "0"
              padding: "0"

            "i._attrib":
              display: "block"
              height: "16px"
              width: "16px"
              position: "absolute"
              bottom: "8px"
              right: "8px"

            "i._dimensions":
              display: "block"
              height: "16px"
              width: "236px"
              position: "absolute"
              bottom: "0"
              right: "0"
              "line-height": "32px"
              height: "32px"
              "text-align": "center"
              "font-size": "10px"
              "font-style": "normal"
              color: "#fff"

          "&:hover":
            "span._pin":
              "background-image": "url(_cdn/_pin_it_button)"
              "background-color": "rgba(0, 0, 0, .50)"

    "@media only screen and (-webkit-min-device-pixel-ratio: 2)":
      "#_logo":
        "background-size": "100px 26px"
        "background-image": "url(_cdn/images/LogoRed.2x.png)"

  msg:
    en:
      cancelTitle: "Cancel"
      noPinDomain: "Sorry, pinning is not allowed from this domain. Please contact the site operator if you have any questions."
      noPinMeta: "Sorry, pinning is not allowed from this page. Please contact the site operator if you have any questions."
      privateDomain: "Sorry, can't pin directly from %privateDomain%."
      noPinnablesFound: "Sorry, couldn't find any pinnable things on this page."
      installed: "Oops!\nThat button doesn't work on Pinterest.\nTry using the red Pin It button at the top of any Pin."

    de:
      cancelTitle: "Abbrechen"
      noPinDomain: "Es tut uns leid, aber von dieser Domain kann nichts gepinnt werden. Bitte kontaktiere den Website-Betreiber, falls du weitere Fragen hast."
      noPinMeta: "Es tut uns leid, aber von dieser Seite kann nichts gepinnt werden. Bitte kontaktiere den Website-Betreiber, falls du weitere Fragen hast."
      privateDomain: "Es tut uns leid, aber du kannst nicht direkt von %privateDomain% pinnen"
      noPinnablesFound: "Es tut uns leid, aber wir konnten auf dieser Seite nichts finden, was du pinnen kÃ¶nntest."
      installed: "Hoppla!\nDieser Button funktioniert auf Pinterest nicht.\nVersuchen Sie es stattdessen mit dem roten â€žPin Itâ€œ-Button, der sich oberhalb jedes Pins befindet."

    es:
      cancelTitle: "Cancelar"
      noPinDomain: "Lo sentimos, no estÃ¡ permitido pinear desde este dominio. Ponte en contacto con el operador del sitio si tienes alguna pregunta."
      noPinMeta: "Lo sentimos, no estÃ¡ permitido pinear desde esta pÃ¡gina. Ponte en contacto con el operador del sitio si tienes alguna pregunta."
      privateDomain: "Lo sentimos, no es posible pinear directamente desde %privateDomain%."
      noPinnablesFound: "Lo sentimos, no hemos encontrado ningÃºn elemento que se pueda pinear en esta pÃ¡gina."
      installed: "Â¡Vaya! \nEse botÃ³n no funciona en Pinterest. \nUsa el botÃ³n Pin It rojo que se encuentra en la parte superior de cualquier Pin."

    "es-mx":
      cancelTitle: "Cancelar"
      noPinDomain: "Lamentablemente, no estÃ¡ permitido pinear desde este dominio. Si quieres hacer consultas, comunÃ­cate con el operador del sitio."
      noPinMeta: "Lamentablemente, no estÃ¡ permitido pinear desde esta pÃ¡gina. Si quieres hacer consultas, comunÃ­cate con el operador del sitio."
      privateDomain: "Lamentablemente, no es posible pinear directamente desde %privateDomain%."
      noPinnablesFound: "Lamentablemente, no se encontraron cosas para pinear en esta pÃ¡gina."
      installed: "Â¡Uy! \nEse botÃ³n no funciona en Pinterest.\nIntenta con el botÃ³n rojo de Pin It, ubicado en la parte superior de cualquier Pin."

    fr:
      cancelTitle: "Annuler"
      noPinDomain: "DÃ©solÃ©, mais vous ne pouvez pas Ã©pingler les contenus de ce domaine. Pour toute question, veuillez contacter l'administrateur du site."
      noPinMeta: "DÃ©solÃ©, mais vous ne pouvez pas Ã©pingler les contenus de cette page. Pour toute question, veuillez contacter l'administrateur du site."
      privateDomain: "DÃ©solÃ©, mais vous ne pouvez pas Ã©pingler directement les contenus de %privateDomain%."
      noPinnablesFound: "DÃ©solÃ©, mais aucun contenu susceptible d'Ãªtre Ã©pinglÃ© n'a Ã©tÃ© trouvÃ© sur cette page."
      installed: "Oupsâ€¦\nCe bouton ne fonctionne pas sur Pinterest.\nEssayez d'utiliser le bouton rouge Pin It en haut de chaque Ã©pingle."

    ja:
      cancelTitle: "&#12461;&#12515;&#12531;&#12475;&#12523;"
      noPinDomain: "ã—è¨³ã‚ã‚Šã¾ã›ã‚“ã€‚HTML ä»¥å¤–ã®ãƒšãƒ¼ã‚¸ã§ãƒ”ãƒ³ã™ã‚‹ã“ã¨ã¯ã§ãã¾ã›ã‚“ã€‚ç”»åƒã‚’ã‚¢ãƒƒãƒ—ãƒ­ãƒ¼ãƒ‰ã—ã‚ˆã†ã¨è©¦ã¿ã¦ã„ã‚‹å ´åˆã¯ã€pinterest.com ã«ã‚¢ã‚¯ã‚»ã‚¹ã—ã¦ãã ã•ã„ã€‚"
      noPinMeta: "ã“ã®ãƒšãƒ¼ã‚¸ã‹ã‚‰ã®ãƒ”ãƒ³ã¯è¨±å¯ã•ã‚Œã¦ã„ã¾ã›ã‚“ã€‚ã”è³ªå•ãŒã‚ã‚‹å ´åˆã¯ã€ã‚µã‚¤ãƒˆé‹å–¶è€…ã«ãŠå•ã„åˆã‚ã›ãã ã•ã„ã€‚"
      privateDomain: "ç”³ã—è¨³ã”ã–ã„ã¾ã›ã‚“ã€ %privateDomain% ã‹ã‚‰ç›´æŽ¥ãƒ”ãƒ³ã™ã‚‹ã“ã¨ã¯ã§ãã¾ã›ã‚“ã€‚"
      noPinnablesFound: "ç”³ã—è¨³ã”ã–ã„ã¾ã›ã‚“ã€ã“ã®ãƒšãƒ¼ã‚¸ã§ãƒ”ãƒ³ã§ãã‚‹ã‚¢ã‚¤ãƒ†ãƒ ã¯è¦‹ã¤ã‹ã‚Šã¾ã›ã‚“ã§ã—ãŸã€‚"
      installed: "Pinterest ã§ã¯ã“ã®ãƒœã‚¿ãƒ³ã¯ä½¿ãˆã¾ã›ã‚“ã€‚\nãƒ”ãƒ³ã®ä¸Šéƒ¨ã«ã‚ã‚‹èµ¤ã„ [ãƒ”ãƒ³] ãƒœã‚¿ãƒ³ã‚’ãŠä½¿ã„ãã ã•ã„ã€‚"

    nl:
      cancelTitle: "Annuleren"
      noPinDomain: "Sorry, het is niet toegestaan om vanaf dit domein te pinnen. Neem contact op met de beheerder van deze website als je vragen hebt."
      noPinMeta: "Sorry, het is niet toegestaan om vanaf dit domein te pinnen. Neem contact op met de beheerder van deze website als je vragen hebt."
      privateDomain: "Sorry, je kunt niet direct pinnen vanaf %privateDomain%."
      noPinnablesFound: "Sorry, er is niets wat je kunt pinnen op deze pagina."
      installed: "Oeps!\nDie knop werkt niet op Pinterest.\nProbeer de rode Pin It-knoppen die boven pins zweven."

    pt:
      cancelTitle: "Cancelar"
      noPinDomain: "Lamentamos, mas nÃ£o Ã© permitido afixar pins a partir deste domÃ­nio. Em caso de dÃºvidas, contacta o operador do site."
      noPinMeta: "Lamentamos, mas nÃ£o Ã© permitido afixar pins a partir desta pÃ¡gina. Em caso de dÃºvidas, contacta o operador do site."
      privateDomain: "Lamentamos, mas nÃ£o Ã© possÃ­vel afixar pins diretamente de %privateDomain%."
      noPinnablesFound: "Lamentamos, mas nÃ£o foi possÃ­vel encontrar nesta pÃ¡gina nenhum conteÃºdo que possa ser afixado."
      installed: "Ups! \nEsse botÃ£o nÃ£o funciona no Pinterest. \nTenta utilizar o botÃ£o vermelho Pin It, que se encontra na parte superior de cada Pin."

    "pt-br":
      cancelTitle: "Cancelar"
      noPinDomain: "NÃ£o Ã© possÃ­vel pinar a partir deste domÃ­nio. Entre em contato com o operador do site se tiver dÃºvidas."
      noPinMeta: "NÃ£o Ã© possÃ­vel pinar a partir desta pÃ¡gina. Entre em contato com o operador do site se tiver dÃºvidas."
      privateDomain: "NÃ£o Ã© possÃ­vel pinar diretamente de %privateDomain%."
      noPinnablesFound: "NÃ£o foi possÃ­vel encontrar nesta pÃ¡gina conteÃºdo que possa ser pinado."
      installed: "Opa!\nEste botÃ£o nÃ£o funciona no Pinterest.\nTente usar o botÃ£o vermelho Pin It, localizado na parte superior de qualquer Pin."

  hashList: [
    /efa3a2deb839/
    /20c46b653b00/
    /9e2089d8b8f2/
    /820a6e7baa0f/
    /293aa4f9b3d0/
    /1529ad2b2cc8/
    /8de5d416e5d2/
    /8c2d5961f7af/
    /540b2374abf1/
    /415215dcadbf/
    /dbafdf055617/
    /871de03c9980/
    /85ae87da6618/
    /1d1d5ffa1d50/
    /1847807c0ea1/
    /08fb2eb6424d/
    /a32353817e45/
    /71c1f4783e6d/
    /79f57d83d54a/
    /eefa602a72ed/
    /32aa39d04eb4/
    /25f7c9982cea/
  ]
)