describe 'BaseModel', () ->
  
  [BaseModel, MockClass] = [null, null]

  beforeEach(inject (_BaseModel_) ->
    BaseModel = _BaseModel_
  )

  describe '.generateFromJSON', ->
    beforeEach ->
      class MockClass extends BaseModel
        @generateFromJSON: (json) -> BaseModel.generateFromJSON(MockClass, json)
        @basePath: '/api/v1/mock_classes'
        myValue: => "My value is '#{@value}'"

    it "parses an array into instances of constructor class", ->
      result = MockClass.generateFromJSON([{ "id": 1, "value": "firstValue"}, { "id": 2, "value": "secondValue"}])
      expect( result[0].constructor ).toEqual(MockClass)
      expect( result[0].myValue() ).toEqual("My value is 'firstValue'")
      expect( result[1].myValue() ).toEqual("My value is 'secondValue'")
      expect( result[1].objectPath() ).toEqual("/api/v1/mock_classes/2")

    it "parses an individual as one item", ->
      result = MockClass.generateFromJSON({ "value": "onlyValue"})
      expect( result.constructor ).toEqual(MockClass)
      expect( result.myValue() ).toEqual("My value is 'onlyValue'") 

  describe 'relation extraction', ->
    
    [HasManyClass, HasOneClass] = [null, null]

    beforeEach ->
      class MockClass extends BaseModel
        constructor: (properties) ->
          @hasManys = @extractHasManyRelation(HasManyClass, properties, 'has_many_objects')
          @hasOne = @extractHasManyRelation(HasOneClass, properties, 'HasOneObject')
          properties = _.extend(this, properties)

        @generateFromJSON: (json) -> BaseModel.generateFromJSON(MockClass, json) 
        myValue: => "My value is '#{@value}'"

      class HasManyClass extends BaseModel
        @generateFromJSON: (json) -> BaseModel.generateFromJSON(HasManyClass, json)
        statement: -> "I am a #{@value} Object"

      class HasOneClass extends BaseModel
        @generateFromJSON: (json) -> BaseModel.generateFromJSON(HasOneClass, json)
        statement: -> "I am a #{@value} Object"
    
    it "extracts correctly, with Ruby key format", ->

      json = 
        value: 'onlyValue'
        has_many_objects: [{ value: "Has Many"}, { value: "Has Many"}]
        HasOneObject: { value: 'Has One' }

      mockObject = MockClass.generateFromJSON(json)
      
      expect( mockObject.myValue() ).toEqual("My value is 'onlyValue'")
      expect( mockObject.hasManys.length ).toEqual(2)
      expect( mockObject.hasManys[0].statement() ).toEqual "I am a Has Many Object"
      expect( mockObject.hasOne.statement() ).toEqual "I am a Has One Object"

  describe "ORM methods", ->
    
    MockClass = null

    beforeEach ->
      class MockClass extends BaseModel
        @generateFromJSON: (json) -> BaseModel.generateFromJSON(MockClass, json)
        @basePath: '/api/v1/mock_classes'

    describe ".all()", ->
      it "sends an HTTP query to the set basePath", ->
        sinon.stub(@http, 'get')
        MockClass.all()

        expect(@http.get.calledWithMatch("/api/v1/wrong_path" )).toEqual false
        expect(@http.get.calledWithMatch(MockClass.basePath)).toEqual true

    describe ".where()", ->
      it "sends an HTTP query to the set basePath", ->
        sinon.stub(@http, 'get')

        MockClass.where({some_condition: 'Some Value'})

        expect(@http.get.calledWithMatch("/api/v1/wrong_path")).toEqual false
        expect(@http.get.calledWithMatch(MockClass.basePath, {params: { conditions: {some_condition: 'Some Value'} } })).toEqual true

    describe ".find()", ->
      it "sends an HTTP query to the object API path", ->
        sinon.stub(@http, 'get')
        MockClass.find(1)

        expect(@http.get.calledWithMatch("#{MockClass.basePath}/1")).toEqual true

    describe ".create()", ->
      it "sends a POST query with the data", ->
        sinon.stub(@http, 'post')
        data = {att1: 'value', att2: 'value2'}
        MockClass.create(data)

        expect(@http.post.calledWithMatch(MockClass.basePath, data)).toEqual true

    describe "#update()", ->
      it "puts data to the object path", ->
        sinon.stub(@http, 'put')

        object = MockClass.generateFromJSON({id: 15})

        object.update({name: 'ObjectName'})

        expect(@http.put.calledWithMatch("#{MockClass.basePath}/15", { name: 'ObjectName' })).toEqual true

    describe '#destroy()', ->
      it "sends a delete request to the object path", ->
        sinon.stub(@http, 'delete')

        object = MockClass.generateFromJSON({ id: 30 })

        object.destroy()

        expect( @http.delete.calledWithMatch("#{MockClass.basePath}/30") ).toEqual true
        expect( @http.delete.calledWithMatch(object.objectPath()) ).toEqual true