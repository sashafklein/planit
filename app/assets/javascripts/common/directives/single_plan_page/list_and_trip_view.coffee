angular.module("Common").directive 'listAndTripView', (ErrorReporter, Mark, Flash, Note) ->
  return { 
    restrict: 'E'
    replace: true
    templateUrl: 'single/tabs/_list_and_trip_view.html'
    scope:
      m: '='
    link: (s, e, a) ->
      
      s.listClass = (mode) -> if mode == 'list' then 'sixteen columns' else 'ten columns'

      s.metaClass = ( meta_category ) -> 
        switch meta_category
          when 'Area' then 'rainbow-print yellow'
          when 'See' then 'rainbow-print green'
          when 'Do' then 'rainbow-print bluegreen'
          when 'Relax' then 'rainbow-print turqoise'
          when 'Stay' then 'rainbow-print blue'
          when 'Drink' then 'rainbow-print purple'
          when 'Food' then 'rainbow-print magenta'
          when 'Shop' then 'rainbow-print pink'
          when 'Help' then 'rainbow-print orange'
          when 'Other' then 'rainbow-print gray'
          when 'Transit' then 'rainbow-print gray'
          when 'Money' then 'rainbow-print gray'
          else 'no-type'
      
      s.typeIcon = (meta_category) -> 
        itemsWithIcon = _.filter( s.m.items, (i) -> i.mark.place.meta_categories[0] == meta_category )
        if itemsWithIcon[0] then itemsWithIcon[0].mark.place.meta_icon else ''

      s.matchingItems = ( category ) ->
        switch s.m.categoryIs
          when 'type' then _.filter( s.m.items, (i) -> i.mark.place.meta_categories?[0] == category )
          when 'alphabetical' then _.filter( s.m.items, (i) -> i.mark.place.names?[0]?[0] == category )
          when 'recent' then _.filter( s.m.items, (i) -> x=i.updated_at.match(/(\d{4})-(\d{2})-(\d{2})/); "#{x[2]}/#{x[3]}/#{x[1]}" == category )
          when 'locale' then _.filter( s.m.items, (i) -> i.mark.place.locality == category )
          else []

      s.nextNote = (item) -> 
        return unless item
        if this_textarea = e.find("textarea#item_" + item.id)
          next_li = this_textarea.parents('li.plan-list-item').next('li.plan-list-item').find('textarea')
          next_ul = this_textarea.parents('.items-in-plan-category').next('.items-in-plan-category').find('textarea').first()
          next_li.focus() if next_li[0]
          next_ul.focus() if next_ul[0] && !next_li[0]
          this_textarea.blur() if !next_li[0] && !next_ul[0]
        return

      s.priorNote = (item) -> 
        return unless item
        if this_textarea = e.find("textarea#item_" + item.id)
          prior_li = this_textarea.parents('li.plan-list-item').prev('li.plan-list-item').find('textarea')
          prior_ul = this_textarea.parents('.items-in-plan-category').prev('.items-in-plan-category').find('textarea').last()
          prior_li.focus() if prior_li[0]
          prior_ul.focus() if prior_ul[0] && !prior_li[0]
          this_textarea.blur() if !prior_li[0] && !prior_ul[0]
        return

  }
