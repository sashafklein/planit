#= require spec_helper

describe 'BaseModel', () ->
  
  [BaseModel, MockClass] = [null, null]

  beforeEach(inject (_BaseModel_) ->
    BaseModel = _BaseModel_
  )

  describe '.generateFromJSON', ->
    beforeEach ->
      class MockClass extends BaseModel
        @generateFromJSON: (json) -> BaseModel.generateFromJSON(MockClass, json)
        myValue: => "My value is '#{@value}'"

    it "parses an array into instances of constructor class", ->
      result = MockClass.generateFromJSON([{ "value": "firstValue"}, { "value": "secondValue"}])
      expect( result[0].constructor ).toEqual(MockClass)
      expect( result[0].myValue() ).toEqual("My value is 'firstValue'")
      expect( result[1].myValue() ).toEqual("My value is 'secondValue'")

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