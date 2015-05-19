angular.module("Directives").directive 'singlePageHeader', (QueryString) ->
  restrict: 'E'
  replace: true
  templateUrl: 'single/_single_page_header.html'
  scope:
    m: '='
  link: (s, e, a) ->
    s.toggleMainMenu = -> s.m.mainMenuToggled = !s.m.mainMenuToggled
