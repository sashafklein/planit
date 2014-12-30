#= require application
#= require angular-mocks
#= require sinon
#= require jasmine-sinon
#= require requirejs

beforeEach(module('ngApp'))

beforeEach inject (_$compile_, $rootScope, $controller, $location, $injector, $timeout, _$httpBackend_, _$http_) ->
  @scope = $rootScope.$new()
  @http = _$http_
  @httpBackend = _$httpBackend_
  @compile = _$compile_
  @location = $location
  @controller = $controller
  @injector = $injector
  @timeout = $timeout
  @model = (name) =>
    @injector.get(name)
  @eventLoop =
    flush: =>
      @scope.$digest()

  @sandbox = sinon.sandbox.create()

afterEach ->
  @httpBackend.resetExpectations()
  @httpBackend.verifyNoOutstandingExpectation()