angular.module("Directives").directive 'mobilePlans', () ->
  return { 
    restrict: 'E'
    replace: true
    templateUrl: 'single/tabs/_mobile_plans.html'
    scope:
      m: '='
    link: (s, e, a) ->

      s.plans = -> 
        return [] unless s.m.view == 'plan' && s.m.plans && s.m.userInQuestionId
        s.plansCertificate = "#{s.m.userInQuestionId}:#{s.timestamp()}"
        return s.lastPlans if s.plansCertificate == s.lastPlansCertificate
        s.lastPlansCertificate = s.plansCertificate
        s.lastPlans = s.m.planManager?.userPlans( s.m.userInQuestionId )

      s.loadPlan = (planId) -> s.m.workingNow = true; s.m.planManager.fetchPlan(planId, s.m.unworking() )

      s.timestamp = -> parseInt( Date.now()/100000 )
    
  }
