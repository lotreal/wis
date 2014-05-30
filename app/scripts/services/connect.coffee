'use strict'

angular.module('wis.connect', [])

.factory('connectService', [
    'socketFactory'
    (socketFactory) ->

        link = (socket, fsm)->

            funcs = []
            for state, stdef of fsm.states
                funcs = _.union funcs, _.keys stdef

            funcs = _.filter funcs, (f)->f.slice(0,1)!='_'
            for f in funcs
                socket.on f, ((f)->
                    (data)->fsm.handle(f, data))(f)

            oriEmit = fsm.emit
            fsm.emit = ->
                args = arguments
                oriEmit.apply fsm, args
                socket.emit.apply socket, args

        return {
            handle: (fsm)->
                socket = socketFactory({
                    ioSocket: io.connect('', query: "rid=#{fsm.rid}")
                })

                socket.on 'connect', ->
                    console.log 'wis connected.'
                    link socket, fsm

                return socket
        }
])
