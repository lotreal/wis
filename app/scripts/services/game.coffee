'use strict'

angular.module('wis.game', ['wis.api', 'wis.player'])

.factory("game", (api, playerService) ->
        timeoutHandler = {}
        setTimeoutIfNo = (fn, timeout, key)->
            clearTimeout(timeoutHandler[key])
            timeoutHandler[key] = setTimeout(fn, timeout)

        fsm = (rid, $scope) ->
            model = $scope.model = {}



            game = new machina.Fsm(
                initialState: 'uninitialized'
                namespace: 'wis'

                load: (rid)->
                    @rid = rid
                    console.log 'sync game data'
                    api.getRoom(rid).then(
                        _.bind(
                            (data)->
                                @handle('initialized', data)
                                @handle('load', data)
                            @
                        )
                        (err)->
                    )

                pending: (timeout)->
                    state = @state
                    back = _.bind(
                        ->@transition(state),
                        @)
                    @exitPending = setTimeout back, timeout
                    @transition('pending')

                states:
                    uninitialized:
                        initialized: (data)->
                            console.log fInit: data
                            self = @
                            model.uid = data.uid
                            model.room = data.room
                            model.profile = data.profile

                            playerService.init(data.uid, data.members)

                            # TODO fix this
                            model.chats = [0..99]

                            $scope.action = ->
                                game.handle('action')

                            $scope.speak = (evt)->
                                if evt.keyCode == 13
                                    if $scope.input
                                        self.emit 'speak', $scope.input
                                        console.log 'input - ', $scope.input
                                        $scope.input = ''

                            $scope.print = ->console.log 'print'

                            state = data.state
                            @transition if state then state else 'ready'

                    ready:
                        _onEnter: ->
                            model.state = @state
                            model.round = 0

                            $scope.getBoard = ->
                                num = playerService.members.length
                                api.teamname(model.room.team, num) if num > 0

                            $scope.isVisible = (key)->
                                return key == 'ready'

                            $scope.actionAvailable = ->
                                console.log flag:playerService.flag(), ready:playerService.allReady(), state: model.state
                                return false unless model.state == 'ready'
                                return true if playerService.flag() != 'master'
                                return playerService.allReady()

                            $scope.$apply() unless $scope.$$phase
                            $('#wis-input').focus()
                            console.log 'enter waitroom'

                        load: (data)->
                            console.log fReady: data

                            _.map playerService.members, (p)->
                                playerService.setFlag(p)

                            model.members = playerService.members

                            showChat = ->
                                _.forEach playerService.members, (p)->
                                    playerService.setBalloon(model, p.uid, p.message)

                            setTimeout showChat, 300

                            @handle('usermod', playerService.me())

                        action: (data)->
                            if playerService.flag() == 'master'
                                @pending(3000)
                                @emit 'start'
                                console.log 'start game'

                            else
                                @emit 'ready', model.uid
                                console.log 'ready'

                        usermod: (data)->
                            return unless data
                            playerService.setFlag(data)
                            console.log "usermod #{data.uid}", data

                            find = playerService.find(data)
                            find = _.merge(find, data)

                            if playerService.isMe(find)
                                label = '准备'
                                label = '取消准备' if find.flag == 'ready'
                                label = '开始' if find.flag == 'master'
                                model.actionLabel = label

                        speak: (chat)->
                            console.log "chat - #{chat.uid}: #{chat.message}"
                            playerService.setBalloon(model, chat.uid, chat.message)

                        start: ->

                    play:
                        _onEnter: ->
                            self = @
                            model.state = @state

                            $scope.isVisible = (key)->
                                return key == 'play'

                            $scope.vote = (idx)->
                                console.log 'vote', idx
                                self.emit 'game:vote', idx, (res)->
                                    $scope.subtitle = res

                        load: (data)->
                            model.word = data.game.word
                            model.scene = data.scene
                            console.log fPlay: data

                            unless data.game.round == undefined
                                @handle('start.round', data.game.round)

                        'start.round': (round)->
                            console.log round: round
                            model.round = round

                        speak: (data)->
                            model.scene = data.scene
                            console.log data
                            # $scope.$apply() unless $scope.$$phase

                    pending:
                        _onEnter: ->
                            model.state = @state

                        'start.forecast': ->
                            clearTimeout @exitPending

                        'start.countdown': (data)->
                            model.actionLabel = sprintf(data.message, data.count)

                        start: (data)->
                            @transition('play')
                            @handle('load', data)

            )

            game.load(rid)
            console.log 'GAME'

            # console.log _.uniq(_.flatten(funcs))
            return game
        return fsm
)
