angular.module('Common').factory 'QueryString', () ->

  class QueryString

    # PUBLIC

    # @tagInclude: (tag) ->
    #   return true if QueryString._currentParamValue('t').indexOf(tag) != -1
      
    # @categoryInclude: (meta_category) ->
    #   return true if QueryString._currentParamValue('c').indexOf(meta_category) != -1
      
    # @otherInclude: (other_tag) ->
    #   return true if QueryString._currentParamValue('o').indexOf(other_tag) != -1      

    @fetchQuery: () ->
      query = if QueryString._currentParamValue('q') then decodeURI( QueryString._currentParamValue('q') ) else null

    @modifyParamValues: (params_to_sluggify) ->
      pathArray = window.location.pathname.split('/')
      pathArray.pop()
      newPath = pathArray.join('/') + "/#{QueryString._sluggify(params_to_sluggify,{})}"
      window.history.pushState("object or string", "Title", newPath )

    @clearParamValues: (params_to_clear) ->
      pathArray = window.location.pathname.split('/')
      pathArray.pop()
      newPath = pathArray.join('/') + "/#{QueryString._sluggify({},params_to_clear)}"
      window.history.pushState("object or string", "Title", newPath )

    # PRIVATE

    @_currentPage: () ->
      return _currentPage if _currentPage
      _currentPage = window.location.pathname.split('/').pop()

    @_removeBlanks: (paramValue) ->
      paramValue.replace(/\s\s+/g, ' ').replace(/^\s*/g, '').replace(/\s*$/g, '') unless !paramValue

    @_currentOrNewParamValue: (paramName, paramValue) ->
      if cleanParamValue = QueryString._removeBlanks( paramValue )
        return encodeURI( "#{paramName}=#{ cleanParamValue }" ) unless !cleanParamValue.length
      else if currentValue = QueryString._removeBlanks( QueryString._currentParamValue(paramName) )
        return encodeURI( "#{paramName}=#{ currentValue }" ) unless !currentValue.length
      else
        ''

    @_paramRegex: (paramName) ->
      new RegExp("(?:[&]|[?])" + paramName + "=", 'i')

    @_currentParamValue: (paramName) -> 
      _slugAfterParamEquals = window.location.href.split('/').pop().split( QueryString._paramRegex(paramName) )
      return _slugThisParamOnly = decodeURI( _slugAfterParamEquals[1].split(/[&]/).shift() ) unless _slugAfterParamEquals.length < 2
      null

    @_sluggify: (params,to_clear) ->
      newSlug = []
      newSlug.push( QueryString._currentOrNewParamValue('q', params.q) ) unless to_clear.q # search query
      newSlug.push( QueryString._currentOrNewParamValue('c', params.c) ) unless to_clear.c # meta-categories
      newSlug.push( QueryString._currentOrNewParamValue('t', params.t) ) unless to_clear.t # tags
      newSlug.push( QueryString._currentOrNewParamValue('l', params.l) ) unless to_clear.l # lat,lon
      newSlug.push( QueryString._currentOrNewParamValue('n', params.n) ) unless to_clear.n # nearby in text
      newSlug.push( QueryString._currentOrNewParamValue('z', params.z) ) unless to_clear.z # zoom
      newSlug.push( QueryString._currentOrNewParamValue('u', params.u) ) unless to_clear.u # users
      newSlug.push( QueryString._currentOrNewParamValue('o', params.o) ) unless to_clear.o # other, e.g. 'wifi', 'open'
      if _(newSlug).compact().value().length > 0
        "#{QueryString._currentPage()}?#{_(newSlug).compact().value().join('&')}" 
      else
        QueryString._currentPage()

    # INITIALIZE

    @initializePage: () ->
      QueryString.modifyParamValues({}) # clean dirty slug

  return QueryString
