mod = angular.module('Models')
mod.factory 'Tags', (QueryString) ->

  class Tags

    # INITIALIZE

    @initializePage: ->
      $('.tag-dropdown-menu-checkbox').click ->
        alert($(this).attr('id'))

  return Tags