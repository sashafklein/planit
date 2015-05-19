angular.module("Services").service "MetaCategory", ->
  class MetaCategory

    @colorClass: (mc) ->
      switch mc
        when 'Area' then 'yellow'
        when 'See' then 'green'
        when 'Do' then 'bluegreen'
        when 'Relax' then 'turqoise'
        when 'Stay' then 'blue'
        when 'Drink' then 'purple'
        when 'Food' then 'magenta'
        when 'Shop' then 'pink'
        when 'Help' then 'orange'
        when 'Other' then 'gray'
        when 'Transit' then 'gray'
        when 'Money' then 'gray'
        else 'no-type'

  return MetaCategory