angular.module("BaseClass")
  .factory "BCCache", ->
    Cache = ->
      privateVariable this, 'cache', (instance, primaryKey) ->
        if (instance and instance[primaryKey] != undefined)
          this[instance[primaryKey]] = instance

      privateVariable this, 'isEmpty', () ->
        not Object.keys(this).length

      privateVariable this, 'where', (terms) -> 
        _.where(this, terms, this)
    Cache
