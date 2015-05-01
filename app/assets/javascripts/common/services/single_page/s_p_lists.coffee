angular.module("Common").service "SPLists", (User, Plan, SPList, QueryString, ErrorReporter) ->
  class SPLists

    constructor: ( user_id ) ->
      self = @
      User.findPlans( user_id )
        .success (response) -> self.lists = _.map( response, (l) -> list = new SPList( Plan.generateFromJSON( l ) ) )            

    removeList: ( plan_id ) ->
      list = @_findList( plan_id )
      return unless confirm("Are you sure you want to delete '#{ list.name }'?")
      list.destroy()
        .success (response) ->
          @lists.splice( @lists.indexOf( list ), 1 ) if @lists.indexOf( list ) > -1
          QueryString.modify({ plan: null })
        .error (response) ->
          ErrorReporter.silentFull( response, 'SinglePagePlans deleteList', { plan_id: plan_id } )

    fetchList: ( plan_id ) ->
      Plan.find( plan_id )
        .success (response) -> 
          @lists.push( new SPList( Plan.generateFromJSON( response ) ) )
        .error (response) -> 
          ErrorReporter.silentFull( response, "SPLists loading list #{ plan_id }" )

    addNewList: ( name ) ->
      return unless name?.length
      Plan.create( plan_name: name )
        .success (response) ->
          list = new SPList( Plan.generateFromJSON( response ) )
          @lists.unshift( list )
          QueryString.modify({ plan: list.id })
        .error (response) ->
          ErrorReporter.silentFull( response, 'SinglePagePlans Plan.create', { plan_name: s.listQuery})

    _findList: ( id ) -> _.find( @lists, (l) -> parseInt( l.id ) == parseInt( list_id ) )

    # s.bestListDate = (list) -> if list.starts_at then list.starts_at else list.updated_at

  return SPLists