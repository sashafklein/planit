mod = angular.module("Models")
mod.factory "BaseModel", ($http) ->
  
  class BaseModel
    constructor: (properties) -> _.extend(this, properties)

    extractHasManyRelation: (factory, properties, key) ->
      if _(properties).has(key)
        rv = factory.generateFromJSON(properties[key])
        delete properties[key]
        return rv
      else
        return []

    extractHasOneRelation: (factory, properties, key) ->
      if _(properties).has(key)
        rv = factory.generateFromJSON(properties[key])
        delete properties[key]
        return rv
      else
        return null

    extractHasManyThroughRelation: (factory, properties, collectionName, foreignKey) ->
      if _(properties).has(collectionName)
        result = []
        for elem in properties[collectionName]
          if _(elem).has(foreignKey)
            result.push(factory.generateFromJSON(elem[foreignKey]))

        return result
      else
        return []

    extractDateTime: (properties, key) ->
      if properties[key]
        rv = moment(properties[key])
        delete properties[key]
        return rv
      else
        return null

    @generateFromJSON: (factory, json) ->
      return null unless json?
      if _(json).isArray()
        objs = []
        for elem in json
          objs.push(new factory(elem))
        return objs
      else
        return new factory(json)

    @objectPath: (id) -> "#{@basePath}/#{id}"
    objectPath: -> @constructor.objectPath(@id)

    @all:  -> $http.get(@basePath)
    @find: (id) -> $http.get( @objectPath(id) )
    @create: (data) -> $http.post(@basePath, data)
    @where: (conditions) -> 
      $http.get(
        @basePath,
        params:
          conditions: conditions
      )

    update: (data) -> $http.put( "#{@objectPath(@id)}/update", data )
    destroy:  -> $http.delete( @objectPath(@id) )
  