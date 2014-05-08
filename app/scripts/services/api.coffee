'use strict'

angular.module('wis.api', [])

.factory("api", [
    "$http", "$q"
    ($http, $q) ->
        return {
            N: (n, start) ->
                start = 0 unless start
                a = ['一','二','三','四','五','六','七','八','九','十','十一','十二','十三','十四','十五','十六','十七','十八','十九','廿','廿一','廿二','廿三','廿四']
                a[n-start]

            teamname: (pattern, num)->
                if _.isString(pattern)
                    return sprintf(pattern, @N(num, 1))
                else
                    pat = pattern[0]
                    replaces = pattern[1]
                    if replaces[num] != undefined
                        n = replaces[num]
                        return sprintf(pat, n)
                    else
                        return @teamname(pat, num)

            getRoom: (rid)->
                d = $q.defer()
                $http.post('/api/room', {rid:rid}).success(
                    (res)->
                        d.reject res[0] if res[0]
                        d.resolve res[1]
                )
                return d.promise
        }
])
