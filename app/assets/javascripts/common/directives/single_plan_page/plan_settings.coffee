angular.module("Common").directive 'planSettings', (Flash, ErrorReporter, RailsEnv, Spinner) ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'single/_plan_settings.html'
    scope:
      m: '='
    link: (s, e, a) ->
      s.pusher = new Pusher( RailsEnv.pusher_key )

      s.copyList = (list) ->
        s._setCopyRedirect(list)

        Spinner.show()
        list.copy()
          .success (response) ->
            s.m.settingsBoxToggle()
          .error (response) ->
            Spinner.hide()
            s.m.settingsBoxToggle()
            ErrorReporter.defaultFull(response, "planSettings copyList", { list_id: list.id })

      s._setCopyRedirect = (list) ->
        channel = s.pusher.subscribe("copy-plan-#{list.id}")
        channel.bind 'copied', (data) -> window.location.replace("/plans/#{data.id}")

  }