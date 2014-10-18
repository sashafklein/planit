Function::inherits = (baseclass) ->
  _constructor = this
  _constructor = baseclass.apply(_constructor)
  return

Function::extend = (Module) ->
  props = new Module() 
  propNames = Object.getOwnPropertyNames(props)
  classPropNames = _.remove propNames, ((propname) -> propname.slice(0, 2) != '__')

  _.each classPropNames, ((cpn) ->
    propDescriptor = Object.getOwnPropertyDescriptor(props, cpn)
    Object.defineProperty this, cpn, propDescriptor
    return
  ), this

Function::include = (Module) ->
  methods = new Module()
  propNames = Object.getOwnPropertyNames(methods)
  instancePropNames = _.remove(propNames, (val) ->
    val.slice(0, 2) is "__"
  )
  oldConstructor = this.new
  this.functionName = ->
    instance = oldConstructor.apply(this, arguments)
    _.each instancePropNames, (ipn) ->
      propDescriptor = Object.getOwnPropertyDescriptor(methods, ipn)
      Object.defineProperty instance, ipn.slice(2), propDescriptor
      return

    instance

  return

privateVariable = (object, name, value) ->
  val = undefined
  Object.defineProperty object, name,
    enumerable: false
    configurable: false
    get: -> val

    set: (newVal) -> 
      val = newVal
      return

  object[name] = value if value isnt 'undefined'
  return

angular.module("BaseClass", [])
  .factory "BaseClass", [ "BCBase", (Base) ->
      BaseClass = {}
      BaseClass.Base = Base
      return BaseClass
    ]