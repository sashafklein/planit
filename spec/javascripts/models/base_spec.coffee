#= require spec_helper

describe 'Base', () ->
  
  [Base, MockClass] = [null, null]

  beforeEach(inject (_Base_) ->
    Base = _Base_
  )

  describe '.generateFromJSON', ->
    beforeEach ->
      class MockClass extends Base
        @generateFromJSON: (json) -> Base.generateFromJSON(MockClass, json)
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