angular.module("Common").service "SPLists", (User, Plan, SPList, QueryString, ErrorReporter) ->
  class SPLists

    constructor: ( user_id ) ->
      @lists = []
      User.findPlans( user_id )
        .success (response) ->
          _.forEach response, (l) ->
            list = new SPList( Plan.generateFromJSON( l ) )
            debugger
            @lists.push( list )

    removeList: ( list_id ) ->
      list = @_findList( list_id )
      return unless confirm("Are you sure you want to delete '#{list.name}'?")
      $('.loading-mask').show()
      list.destroy()
        .success (response) ->
          listIndex = s.m.lists.indexOf( list )
          s.m.lists.splice( listIndex, 1 ) if listIndex > -1
          s.m.resetList() 
          $('.loading-mask').hide()
          return
        .error (response) ->
          ErrorReporter.silentFull( response, 'SinglePagePlans deleteList', { plan_id: s.m.list.id } )
          $('.loading-mask').hide()
          return

    fetchList: ( list_id ) ->
      Plan.find( plan_id )
        .success (response) -> 
          @lists.push( new SPList( Plan.generateFromJSON( response ) ) )
          return
        .error (response) -> 
          ErrorReporter.silentFull( response, "SPLists loading list #{ list_id }" )
          return

    addNewList: ( name ) ->
      return unless name?.length
      $('.loading-mask').show()
      $timeout(-> $('#place-nearby').focus() if $('#place-nearby') )
      Plan.create( plan_name: name )
        .success (response) ->
          $('.loading-mask').hide()
          list = new SPList( Plan.generateFromJSON( response ) )
          @lists.unshift( list ) if @lists && !@_findList( list.id )
          $timeout(-> QueryString.modify({ plan: list.id }) )
          return
        .error (response) ->
          $('.loading-mask').hide()
          ErrorReporter.silentFull( response, 'SinglePagePlans Plan.create', { plan_name: s.listQuery})
          return

    _findList: ( id ) -> _.find( @lists, (l) -> parseInt( l.id ) == parseInt( list_id ) )

    # s.bestListDate = (list) -> if list.starts_at then list.starts_at else list.updated_at

  return SPLists