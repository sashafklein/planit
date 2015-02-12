angular.module("RenderHtml", []).directive "renderHtml", ($compile) ->
  restrict: "A"
  scope:
    renderHtml: '@'
  link: (scope, element, attrs) ->
    scope.$watch "renderHtml", (newVal) ->
      linkFunc = $compile(newVal)
      element.html(linkFunc(scope))