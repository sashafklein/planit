angular.module("Services").service 'ClassFromString', ->
  class ClassFromString

    @toClass: ->
      list = _.map arguments, (arg) ->
        array = ClassFromString._removeSymbols( String(arg) ).split(' ')
        _.map( array , (w) -> w.toLowerCase() ).join('-')
      _.compact( list ).join("-")

    @_removeSymbols: (string) ->
      copy = string
      copy.replace(/[^a-zA-Z0-9 ]/g, "")

  return ClassFromString