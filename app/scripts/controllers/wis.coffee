'use strict'
angular.module('WisApp').controller 'WisCtrl', [
    '$scope', 'socketFactory', '$routeParams', 'localize', '$cookies'
    ($scope, socketFactory, $routeParams, localize, $cookies) ->
        ctx =
            user:
                id: $cookies['wis:uid']
            player
            waitRoomAction: '准备'

        $scope.ctx = ctx

        $('#wis-input').focus();

        fsm = new machina.Fsm(
            initialState: 'uninitialized'
            states:
                uninitialized:
                    initialized: (players)->
                        @me = _.find players, (p)->p.uid == $scope.uid
                        if @me
                            console.log  @me.flag
                            @transition 'ready'

                ready:
                    _onEnter: ->
                        @round = 0
                        console.log 'enter ready'
        )

        $scope.uid = $cookies['wis:uid']

        roomId = $routeParams.roomId

        fmt = (n)->
            a = ['一','双','三','四','五','六','七','八','九','十','十一','十二','十三','十四','十五','十六','十七','十八','十九','廿','廿一','廿二','廿三','廿四']
            a[n-1]

        # $scope.chats = []
        # TODO fix this
        $scope.chats = [0..99]

        $scope.fmt = fmt
        $scope.print = ->console.log 'print'

        init = (room)->
            $scope.room = room
            $scope.subtitle = room.name

        socket = null

        connectServer = ->
            socket = socketFactory({
                ioSocket: io.connect('', query: "rid=1ntlvb7r&token=t")
            })

            socket.on 'connect', ->
                socket.emit 'game:load', {}, (res)->
                    console.log load: res
                    $scope.players = res

            # socket.emit 'game:create', {}, (room)->
            #     init(room)

            socket.on 'game:chat', (chat)->
                index = chat.index
                $scope.chats[index] = chat.message
                console.log "#{index}: #{chat.message}"
                el = $('#balloon-'+index)
                el.triggerHandler('focus')


            socket.on 'game:player:update', (list) ->
                # fsm.transition('uninitialized')
                # fsm.handle 'initialized', list
                $scope.user = _.find list, (p)->
                    p.uid == $scope.uid
                # $scope.realStart = if $scope.user.flag == 'master' then '开始' else '准备'
                $scope.realStart = 'master'
                $scope.players = list
                # $scope.title = sprintf($scope.room.team, fmt($scope.list.length))
                console.log 'game:player:update'

            socket.on 'game:start:count', (data) ->
                $scope.subtitle = sprintf(data.message, data.count)

            socket.on 'game:deal', (game)->
                $scope.title = game.word

            socket.on 'game:play:begin', (round)->
                $scope.subtitle = sprintf('康熙字典（第 %d 版）', round)
                $scope.list = []

            socket.on 'game:vote:begin', ->
                $scope.subtitle = '请点选投票'

            socket.on 'game:vote:result', (vote)->
                $scope.list = vote

            socket.on 'game:speak', (msg)->
                console.log msg
                $scope.list = msg

            socket.on 'game:over', (data)->
                $scope.list = data
                $scope.subtitle = '考试结果'

            socket.on 'game:ready', (res)->
                find = _.find $scope.players, (p)->p.uid == res.uid
                find.ready = res.ready
                if find.uid == ctx.user.id
                    $scope.ctx.waitRoomAction = if find.ready then '取消准备' else '准备'

            return socket

        $scope.connect = ->
            socket = connectServer()
            console.log 'connect', socket

        $scope.disconnect = ->
            socket.disconnect()
            socket = null
            console.log 'disconnect'

        $scope.debug = ->
            console.log 'debug'
            socket.emit 'game:debug', {}

        $scope.start = ->
            socket.emit 'game:ready', ctx.user.id

        $scope.startGame = ->
            console.log 'start'
            socket.emit 'game:start', {}

        $scope.vote = (idx)->
            socket.emit 'game:vote', idx, (res)->
                $scope.subtitle = res

        $scope.keyPress = (evt)->
            if evt.keyCode == 13
                if $scope.input
                    socket.emit 'game:speak', $scope.input
                    $scope.input = ''


        $scope.realStart = '准备'
        connectServer()
        return
]
