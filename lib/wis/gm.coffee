'use strict'
context = require('../context')
io = require('../context').get('io')
module.exports = (()->
    console.log io
    class GM
        constructor: (@team)->

        countdown: (count, message, done)->

    return {
        get: (team)->
            context.one('gm:'+team.id, ()->new GM(team))
    }
)()
