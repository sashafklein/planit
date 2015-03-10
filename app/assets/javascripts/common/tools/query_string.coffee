angular.module('Common').factory 'QueryString', () ->

  class QueryString

    # PUBLIC

    @get: ->
      hash = {}
      if slug = QueryString._slug()
        for kv in slug.split("&")
          hash["#{ kv.split("=").shift() }"] = decodeURI( kv.split("=").pop() )
      return hash

    @reset: ->
      @set( null ) 

    @set: (hash) ->
      hash = QueryString._clean(hash)
      return window.history.pushState("object or string", "Title", QueryString._path() ) if !hash
      newPath = QueryString._generate( hash )
      window.history.pushState("object or string", "Title", newPath )

    @modify: (object) ->
      hash = QueryString.get()
      key = Object.keys(object)[0]
      hash[key] = object[key]
      hash = QueryString._clean( hash )
      return window.history.pushState("object or string", "Title", QueryString._path() ) if !hash
      newPath = QueryString._generate( hash )
      window.history.pushState("object or string", "Title", newPath )

    # PRIVATE

    @_clean: (hash) ->
      _.pick(hash, _.identity)

    @_generate: (hash) ->
      "#{QueryString._path()}?#{ QueryString._join( hash ) }"

    @_join: (hash) ->
      _.map(hash, ( (v,k) -> "#{k}=#{ encodeURI( v ) }" )).join("&")

    @_slug: ->
      initial = window.location.href.split('/').pop()
      unless initial.indexOf("?") == -1
        return initial.split("?").pop()
      return null

    @_path: -> 
      patharray = window.location.href.split('/')
      page = patharray.pop()
      page = page.split('?').shift()
      patharray.concat(page).join("/")

  return QueryString
