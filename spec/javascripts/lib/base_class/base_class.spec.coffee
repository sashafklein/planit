describe 'BaseClass', ->
  describe 'Inheritance', ->
    beforeEach  ->

      SomeBaseClass = (attributes) ->
        _constructor = this
        _prototype   = _constructor.prototype

        _constructor.new = (attributes) ->
          instance = new _constructor(attributes)
          return instance

        _prototype.$save = angular.noop
      
      Post.inherits(SomeBaseClass)
      
    it 'adds methods to the child class', ->
      expect(Post.new).toBeDefined()

    it 'adds methods to the instances', ->
      post = Post.new({})
      expect(post.$save).toBeDefined()

  describe 'Extension', ->
    beforeEach ->

      Postable = ->
        this.posted = true
        this.post = -> 
        Object.defineProperty this, 'poster', (get: -> 'me')

      Post.extend(Postable)

    it "adds the properties from the mixin to the class", ->
      expect(Post.posted).toBe true

    it "adds functions from the mixin to the class", ->
      expect(Post.post).toBeDefined()

    it "adds definedProperties from the mixin to the class", ->
      expect(Post.poster).toEqual('me')

  describe 'Inclusion', ->
    post = {}
    beforeEach ->
      Postable = ->
        this.__posted = true
        this.__post = ->

        Object.defineProperty this, '__poster', (get: -> 'me')

      Post.include(Postable)
    
      post = Post.new({})

    it "adds the properties from the mixin to the object", ->
      expect(post.posted).toBe true

    it "adds functions from the mixin to the object", ->
      expect(post.post).toBeDefined()

    it "adds definedProperties from the mixin to the object", ->
      expect(post.poster).toEqual('me')