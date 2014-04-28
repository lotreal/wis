passport = require('./passport')
game = require('./game')
model = require('./model')
Promise = require('bluebird')

module.exports = (socket) ->
    sid = socket.handshake.sessionID
    uid = socket.handshake.uid

    sss = id:uid, io:socket.id

    model.game.add(sss)
    console.log('A socket with UID ' + uid + ' connected!')

    updatePlayer = (socket)->
        players = model.game.status()
        Promise.all((model.user.id(p.id) for p in players)).then (fills)->
            p.profile = fills[i].profile for p, i in players
            socket.emit 'room:join', players
            socket.broadcast.emit 'room:join', players

    updatePlayer(socket)

    socket.on 'disconnect', (a, b, c)->
        console.log arg1:a, arg2:b
        console.log('A socket with UID ' + uid + ' disconnected!')
        model.game.remove(sss)
        updatePlayer(socket)

    context =
        uid: uid
        sid: sid
        io:  socket.id

    game.GameManager.register(context)

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
