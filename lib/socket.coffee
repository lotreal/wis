passport = require('./passport')
# game = require('./game')
model = require('./model')
Promise = require('bluebird')

module.exports = (socket) ->
    sid = socket.handshake.sessionID
    uid = socket.handshake.uid
    rid = '1ntlvb7r' # room id

    io = require('./context').get('io')
    room = 'game'
    team = model.team.get(room)

    GM = require('./wis/gm').get(team)

    socket.join('team0')
    socket.join(room)

    me = id:uid, socket:socket.id

    team.add(me)
    console.log('A socket with UID ' + uid + ' connected!')

    updatePlayer = (socket)->
        players = team.status()
        Promise.all((model.user.id(p.id) for p in players)).then (fills)->
            p.profile = fills[i].profile for p, i in players
            io.sockets.in(room).emit 'room:join', players
            console.log GM

    updatePlayer(socket)

    socket.on 'disconnect', (a, b, c)->
        console.log arg1:a, arg2:b
        console.log('A socket with UID ' + uid + ' disconnected!')
        team.remove(me)
        updatePlayer(socket)

    # getUser = ()->
    #     passport.getToken(socket.handshake.headers.cookie)

    socket.on 'room:enter', (cxt, fn)->
        # getUser()
        #     .then((profile)->
        #         console.log 'room:enter'
        #         fn profile
        #         socket.broadcast.emit('room:enter', profile);
        #     )


        # socket.join cxt.user.id
        # game.join game.player(cxt.user.id), game.room(cxt.room.id)
        # # game.debug()
        # getUser()
        #     .then((profile)->
        #         fn profile.slogan
        #     )

    socket.on 'echo', (msg) ->
        console.log msg
        socket.emit 'echo', msg

    socket.on 'start:game', ()->
        console.log socket

    countdown = (count, message, done)->

    countdown(6, '服务器正在出题(%d)', ()->
        socket.emit 'start:game'
        )

    # io.sockets.sockets[data.to].emit
    # send(player, channel, content)
    startGame = ()->
        all = team.status()
        role =
            spy: 1
            blank: 1
            civil: '*'
        return
    return
