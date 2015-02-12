mod = angular.module('Controllers')
mod.controller "ApplicationCtrl", (ClickControls) ->

  userLocation = undefined

  $('.dropdown-toggle').dropdown()
  $('.popover-toggle').popover({ html: true })
  $('#planit-modal').modal()
  $('#planit-modal').on 'shown.bs.modal', -> $('#planit-modal').focus()
  $('#planit-modal-new').on 'shown.bs.modal', -> showPosition(userLocation)
  $('.search-teaser').click -> searchToggleOn()
  $(".search-close, html").click -> searchToggleOff()
  $('.expanded-search-and-filter, .search-teaser, .filter-dropdown-menu').click (event) -> event.stopPropagation()

  searchToggleOn = () -> 
    $(".search-and-filter-wrap").fadeOut("fast")
    $(".logo-container").fadeOut("fast")
    $(".top-menu-container").fadeOut("fast")
    $(".expanded-search-and-filter").fadeIn("fast")
    $('.initial-header').addClass("focused")
    $("#input-search-field").focus()
  searchToggleOff = () -> 
    $('.initial-header').removeClass("focused")
    $(".expanded-search-and-filter").fadeOut('fast')
    $(".logo-container").fadeIn("fast")
    $(".top-menu-container").fadeIn("fast")
    $(".search-and-filter-wrap").fadeIn("fast")
    $('#search-teaser-text').html('') if $('#input-search-field').val().length == 0
  searchToggleText = () ->
    searchVal = $('#input-search-field').val()
    $('#search-teaser-text').html(searchVal)
    searchToggleOff() unless searchVal.length == 0

  $('#input-search-button').click -> searchToggleText()
  $('#input-search-field').keyup -> if event.keyCode == 13 then $('#input-search-button').click()

  $('.input-with-clear').keyup -> $(this).next().toggle Boolean($(this).val())
  $('.clear-input-button').toggle Boolean($('.input-with-clear').val())
  $('.clear-input-button').click -> $(this).prev().val('').focus(); $(this).hide()

  getLocation = ->
    if navigator.geolocation
      navigator.geolocation.getCurrentPosition( locationResult )      
  locationResult = (position) -> 
    userLocation = position
  showPosition = (position) ->
    getLocation() unless position && (position.timestamp + 300000 > $.now())
    if position
      $('.new-pin-nearby#nearby').val [position.coords.latitude,position.coords.longitude].join(',')
      $('.new-pin-nearby#nearby').next().toggle Boolean($('.new-pin-nearby#nearby').val())
  getLocation()

  $('.edit-place, .edit-places').click -> 
    ClickControls.placeEdits( $(this).attr('id'), $(this).attr('data-place-ids') )


