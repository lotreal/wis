passport = require('./passport')
game = require('./game')
model = require('./model')

module.exports = (socket) ->
    sid = socket.handshake.sessionID
    uid = socket.handshake.uid

    sss = uid:uid, io:socket.id

    model.game.add(sss)
    console.log('A socket with UID ' + uid + ' connected!')

    socket.on 'disconnect', ()->
        console.log('A socket with UID ' + uid + ' disconnected!')
        model.game.remove(sss)

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


    socket.emit 'room:join', game.test

    socket.on 'echo', (msg) ->
        console.log msg
        socket.emit 'echo', msg
