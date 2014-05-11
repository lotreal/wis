'use strict'

angular.module('wis.game', ['wis.api'])

.factory("game", [
    "api", "$q"
    (api, $q) ->
        timeoutHandler = {}
        setTimeoutIfNo = (fn, timeout, key)->
            clearTimeout(timeoutHandler[key])
            timeoutHandler[key] = setTimeout(fn, timeout)

        fsm = ($scope) ->
            model = $scope.model

            class Player
                @get: (p)->
                    return new Player(p.uid)

                constructor: (@uid) ->

                @setFlag: (p)->
                    p.flag = ''
                    p.flag = 'ready' if p.isReady
                    p.flag = 'master' if p.isMaster
                    return p

                @find: (player)->
                    return _.find model.members, (p)->p.uid == player.uid

                @isMe: (player)->
                    return player.uid == model.profile.uid

                @me: ->
                    @find(model.profile)

                @flag: ->
                    @setFlag(@me()).flag

                @setBalloon: (uid, message)->
                    return unless message
                    index = _.findIndex(model.members, uid:uid)
                    model.chats[index] = message
                    # trigger 'focus' let popover show
                    ballon = $('#balloon-'+index)
                    ballon.triggerHandler('focus')
                    hide = ->ballon.triggerHandler('blur')
                    setTimeoutIfNo(hide, 7000, "hide-ballon-#{uid}")

                @allReady: ->
                    _.every(model.members, (p)->p.isMaster || p.isReady)


            game = new machina.Fsm(
                initialState: 'uninitialized'
                namespace: 'wis'

                sync: (rid)->
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
                            model.room = data.room
                            model.profile = data.profile

                            # TODO fix this
                            model.chats = [0..99]

                            $scope.action = ->
                                game.handle('action')

                            $scope.speak = (evt)->
                                if evt.keyCode == 13
                                    if $scope.input
                                        self.emit 'wis:speak', $scope.input
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
                                num = model.members.length
                                api.teamname(model.room.team, num) if num > 0

                            $scope.isVisible = (key)->
                                return key == 'ready'

                            $scope.actionAvailable = ->
                                console.log flag:Player.flag(), ready:Player.allReady(), state: model.state
                                return false unless model.state == 'ready'
                                return true if Player.flag() != 'master'
                                return Player.allReady()

                            $scope.$apply() unless $scope.$$phase
                            $('#wis-input').focus()
                            console.log 'enter waitroom'

                        load: (data)->
                            console.log fReady: data
                            _.map data.members, (p)->
                                Player.setFlag(p)

                            model.members = data.members

                            showChat = ->
                                _.forEach model.members, (p)->
                                    Player.setBalloon(p.uid, p.message)

                            setTimeout showChat, 300

                            @handle('usermod', Player.me())

                        action: (data)->
                            if Player.flag() == 'master'
                                @pending(3000)
                                @emit 'wis:start'
                                console.log 'start game'

                            else
                                @emit 'wis:ready', model.profile.uid
                                console.log 'ready'

                        usermod: (data)->
                            return unless data
                            Player.setFlag(data)
                            console.log "usermod #{data.uid}", data

                            find = Player.find(data)
                            find = _.merge(find, data)

                            if Player.isMe(find)
                                label = '准备'
                                label = '取消准备' if find.flag == 'ready'
                                label = '开始' if find.flag == 'master'
                                model.actionLabel = label

                        speak: (chat)->
                            console.log "chat - #{chat.uid}: #{chat.message}"
                            Player.setBalloon(chat.uid, chat.message)

                        start: ->

                    play:
                        _onEnter: ->
                            model.state = @state

                            $scope.isVisible = (key)->
                                return key == 'play'

                            $scope.vote = (idx)->
                                @emit 'game:vote', idx, (res)->
                                    $scope.subtitle = res

                        load: (data)->
                            model.word = data.game.word
                            console.log fPlay: data

                            unless data.game.round == undefined
                                @handle('start.round', data.game.round)

                        'start.round': (round)->
                            console.log round: round
                            $scope.getBoard = ->
                                sprintf('第 %d 版', round)

                        speak: (chat)->
                            console.log "chat - #{chat.uid}: #{chat.message}"
                            console.log chat


                    pending:
                        _onEnter: ->
                            model.state = @state

                        'start.forecast': ->
                            clearTimeout @exitPending

                        'start.countdown': (data)->
                            model.actionLabel = sprintf(data.message, data.count)

                        start: (data)->
                            load =
                                game:
                                    word:data.word

                            @transition('play')
                            @handle('load', load)

            )
            return game
        return fsm
])
