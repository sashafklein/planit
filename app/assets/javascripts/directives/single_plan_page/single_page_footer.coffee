angular.module("Directives").directive 'singlePageFooter', () ->
  restrict: 'E'
  replace: true
  templateUrl: 'single/_single_page_footer.html'
  scope:
    m: '='
  link: (s, e, a) ->
