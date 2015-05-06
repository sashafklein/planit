angular.module("Services").service "Plural", ->
  class Plural
    
    @compute: (word) ->
      switch word
        when 'country' then 'countries'
        when 'region' then 'regions'
        when 'locality' then 'localities'
        when 'sublocality' then 'sublocalities'
        else word + 's'

  return Plural