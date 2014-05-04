'use strict'
_ = require('lodash')

module.exports = (->
    class Vote
        constructor: (@amount)->
            @getted = ([i, 0] for i in [0..@amount-1])

            @detail = []
            @voted = 0

        vote: (from, to)->
            # check repeat vote
            unless _.find(@detail, (d)->d[0] == from)
                @voted++
                get = @getted[to][1]
                @getted[to] = [to, ++get]
                @detail.push([from, to])

        # return: [[ 7, 0 ],[ 0, 0.1 ],[ 3, 0.1 ],[ 4, 0.1 ],[ 9, 0.1 ],[ 8, 0.4 ]]
        percentage: ->
            p = ([i, get[1]/@amount] for get, i in @getted)
            return _.sortBy(p, (i)->i[1])

        end: ->
            sp = @percentage()

            if @amount == 1
                return end:true, hit:0

            no1 = sp.pop()
            no2 = sp.pop()
            if no1[1] > (no2[1] + (@amount - @voted)/@amount)
                return end:true, hit:no1[0]
            else
                if @amount == @voted
                    return end:true, hit:-1
                else
                    return end:false, hit:-1

        result: ->
            hit = @end()
            hit = hit.hit

            fillout = (i, detail)->
                return {
                    getted: i[1]
                    hit: i[0]==hit
                    voted: v[0] for v in _.filter(detail, (d)->d[1]==i[0])
                }
            fillout(i, @detail) for i in @getted

    return Vote
)()
