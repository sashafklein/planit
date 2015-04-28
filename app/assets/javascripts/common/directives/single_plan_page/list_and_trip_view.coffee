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

      s.toDate = (yymmdd) -> 
        if yymmdd && yymmdd.length == 6
          "Updated on #{s.noneIfZero(yymmdd[2])}#{yymmdd[3]} / #{s.noneIfZero(yymmdd[4])}#{yymmdd[5]} / #{yymmdd[0]}#{yymmdd[1]}"
        else
          'Undated'

      s.noneIfZero = (digit) -> if digit == '0' then '' else digit

      s.matchingItems = ( category ) ->
        switch s.m.categoryIs
          when 'type' then _.filter( s.m.items, (i) -> i.mark.place.meta_categories?[0] == category )
          when 'alphabetical' then _.filter( s.m.items, (i) -> i.mark.place.names?[0]?[0] == category )
          when 'recent' then _.filter( s.m.items, (i) -> x=i.updated_at.match(/(\d{4})-(\d{2})-(\d{2})/); "#{x[2]}/#{x[3]}/#{x[1]}" == category )
          when 'locale' then _.filter( s.m.items, (i) -> i.mark.place.locality == category )
          else []

      s.ownerLoves = (item) -> _.includes( item.mark.place.lovers , s.m.list.user_id )
      s.ownerVisited = (item) -> _.includes( item.mark.place.visitors , s.m.list.user_id )

      s.currentUserSave = (item) -> _.filter( s.m.items, (i) -> i.id == item.id )[0].mark.place.savers.push s.m.currentUserId
      s.currentUserUnsave = (item) -> _.filter( s.m.items, (i) -> i.id == item.id )[0].mark.place.savers.splice( _.filter( s.m.items, (i) -> i.id == item.id )[0].mark.place.savers.indexOf( s.m.currentUserId ), 1 )
      s.currentUserSaved = (item) -> _.includes( item.mark.place.savers , s.m.currentUserId )

      s.currentUserLove = (item) -> _.filter( s.m.items, (i) -> i.id == item.id )[0].mark.place.lovers.push s.m.currentUserId
      s.currentUserUnlove = (item) -> _.filter( s.m.items, (i) -> i.id == item.id )[0].mark.place.lovers.splice( _.filter( s.m.items, (i) -> i.id == item.id )[0].mark.place.lovers.indexOf( s.m.currentUserId ), 1 )
      s.currentUserLoves = (item) -> _.includes( item.mark.place.lovers , s.m.currentUserId )

      s.currentUserBeen = (item) -> _.filter( s.m.items, (i) -> i.id == item.id )[0].mark.place.visitors.push s.m.currentUserId
      s.currentUserUnbeen = (item) -> _.filter( s.m.items, (i) -> i.id == item.id )[0].mark.place.visitors.splice( _.filter( s.m.items, (i) -> i.id == item.id )[0].mark.place.visitors.indexOf( s.m.currentUserId ), 1 )
      s.currentUserVisited = (item) -> _.includes( item.mark.place.visitors , s.m.currentUserId )

      s.fsOpen = (item, doIt) ->
        return unless doIt and item.placeHref()
        window.open(item.placeHref(), '_blank')
        return

      s.saveNote = (item) ->
        return unless item?.note && item?.note.length > 0
        item.notesSearched = false
        Note.create({ note: { object_id: item.id, object_type: item.class, body: item.note } })
          .success (response) ->
            item.note = response.body
            item.notesSearched = true
          .error (response) ->
            ErrorReporter.defaultFull( response, "singlePagePlans - saveNote", { object_id: item.id, object_type: item.class, text: note })
            item.note = null
            item.notesSearched = true

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

      s.deleteItem = (item) ->
        return unless confirm("Delete #{item.mark.place.name} from '#{s.m.list.name}'?")
        return unless item?.mark?.place?.id
        item.destroy()
          .success (response) ->
            itemsWithPlace = _.filter( s.m.items, (i) -> i.mark.place.id == item.mark.place.id )
            itemsIndices = _.map( itemsWithPlace, (i) -> s.m.items.indexOf(i) )
            _.forEach(itemsIndices, (index) -> s.m.items.splice(index, 1) unless index == -1 )
            # # # manifestIndices = if s.manifestItems?.length then _(s.manifestItems).filter( (i) -> i.mark?.place.id == response.mark?.place.id ).map('index').value()
            # # _.forEach(manifestIndices, (index) -> s.manifestItems.splice(index, 1) unless index == -1 )
            for list in _.uniq( _.compact([s.m.list, _.find(s.m.lists, (l) -> l.id == s.m.list.id)]) )
              placeIdIndex = list.place_ids.indexOf( item.mark.place.id )
              if placeIdIndex != -1 then list.place_ids.splice( placeIdIndex, 1 )
              list.best_image = null if s.m.items?.length == 0
            s.m.sortItems()
            Mark.remove( item.mark.place.id )
              .success (response) -> Flash.success("'#{item.mark.place.names[0]}' Deleted")
              .error (response) -> ErrorReporter.report({ place_id: item.mark.place.id, user_id: s.m.currentUserId, context: "Inside singlePagePlans directive, deleting a mark" })
          .error (response) ->
            ErrorReporter.defaultFull( response, 'singlePagePlans delete(item)', { item_id: item.id })

  }
