angular.module("BaseClass")
  .factory "BCBase", ['BCCache', (Cache) ->
    Base = (attributes) ->
      _constructor = this
      _prototype = _constructor.prototype
      privateVariable(_constructor, 'primaryKey', 'id')
      
      cache = (instance) ->
        _constructor.cached.cache(instance, _constructor.primaryKey)

      _constructor.new = (attributes) ->
        instance = new _constructor(attributes)
        cache(instance)
        return instance

      _constructor.cached = new Cache()

    return Base
  ]