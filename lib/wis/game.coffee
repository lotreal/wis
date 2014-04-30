'use strict'
context = require('../context')
Model = require('../model')
io = context.get('io')
Promise = require('bluebird')
_ = require('lodash')
sn = require('./sn')
Stately = require('stately.js')

module.exports = ()->
    game = Stately.machine({
        READY:
            addPlayer: (userID, socketID)->
                player = Model.player.one(userID, socketID)
                @teams.all.add(player)
                socket = io.sockets.sockets[player.socket]
                socket.join(@id_team_all)

                @player = if @player == undefined then 1 else ++@player
                console.log add: 'player ' + @player #, profile: profile
            go: ->@START
        START:
            init: ->
                console.log send: 'words'
                @PLAY
        PLAY:
            play: ->
                @round = if @round == undefined then 1 else ++@round
                console.log round:@round
                @VOTE
        VOTE:
            vote: ->
                console.log vote:@round
                if @round == 2
                    console.log result: true
                    return @OVER
                else
                    return @PLAY
        OVER:
            restart: ->
                console.log restart: true
                @START
    }).bind((event, oldState, newState)->
        transition = oldState + ' => ' + newState
        # console.log transition
        return
    )


    game.addPlayer('lot').addPlayer('nine').go().init().play().vote().play().vote().restart()
