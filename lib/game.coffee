'use strict'
userManager = require('./model').user
uuid = require('node-uuid')

module.exports = (()->
    class Player
        constructor: (@profile)->

        id: ()->
            @profile.uid

        profile: ()->
            @profile

        joinGame: (game)->
            game.add(@)

    class Game
        constructor: ()->
            @id = uuid.v4()
            @players = []

        add: (player)->
            @players.push player
            return player

    class Presenter
        constructor: (@options)->

        ready: (socket)->
            socket.on 'join:game', ()->
                # getUser()
                #     .then((profile)->
                #         socket.broadcast.emit('join:game', profile);
                #     )

    GameManager = (->
        store = {}
        gameStore = {}
        playerStore = {}

        return {
            status: ()->
                store

            register: (context)->
                store[context.uid] = context
                return context

            getPlayer: (uid)->
                player = playerStore[uid]
                if (!player)
                    profile = userManager.find(uid)
                    player = new Player(profile)
                    playerStore[uid] = player
                return player

            registerPlayer: (profile)->
                player = new Player(profile)
                playerStore[player.id()] = player
                return player

            queryGame: ()->
                game = new Game()
                gameStore[game.id] = game
                return game

            queryPlayer: ()->
                playerStore
        }
    )()

    main = ()->
        GameManager.registerPlayer user for user in userManager.all()

        game = GameManager.queryGame()

        player.joinGame(game) for id, player of GameManager.queryPlayer()

        game.players

    main() if !module.parent

    return {
        GameManager: GameManager
        test: main()
    }
)()
