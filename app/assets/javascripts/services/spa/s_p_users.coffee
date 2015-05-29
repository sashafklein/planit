angular.module("SPA").service "SPUsers", (CurrentUser, User, Plan, QueryString, ErrorReporter) ->
  class SPUsers

    constructor: ( userId ) ->
      self = @
      self.users = {}
      self.users[ CurrentUser.id ] = CurrentUser
      self.usersQueried = []
      @fetch( userId )

    fetch: ( userId ) ->
      self = @
      return unless userId
      return self.users[ userId ] if self.users[ userId ]
      return unless self.fetchingUser != userId
      self.fetchingUser = userId
      User.find( userId )
        .success (response) -> 
          self.users[ response.id ] = response
          self.fetchingUser = null
          self.trustCircle( response.id )
        .error (response) -> 
          self.fetchingUser = null
          QueryString.modify({u:null})
          ErrorReporter.silent( response, 'SinglePageUsers trying to fetch User', user_id: userId )
      return self.users[ userId ]

    trustCircle: ( userId ) ->
      self = @ 
      userId = parseInt(userId)
      return unless userId && CurrentUser.id
      return [ self.fetch( userId ) ] unless userId == CurrentUser.id
      userTrustCircleFound = _.filter( self.users, (u) -> _.include( self.users[ userId ].trusts, u.id ) ) if self.users[ userId ]?.trusts
      return userTrustCircleFound if userTrustCircleFound?.length
      return unless self.fetchingUserTrustCircle != userId
      self.fetchingUserTrustCircle = userId
      User.trustCircle( userId )
        .success (responses) ->
          trusts = [ userId ]
          _.forEach responses, (r) -> 
            trusts.push r.id
            self.users[ parseInt(r.id) ] = r unless self.users[ parseInt(r.id) ]
          self.users[ userId ].trusts = trusts
          self.fetchingUserTrustCircle = null
        .error (response) -> 
          self.fetchingUserTrustCircle = null
          ErrorReporter.silent( response, 'SinglePageUsers fetching Trust Circle', user_id: userId )
      return [ self.fetch( userId ) ]

  return SPUsers