module.exports = (socket) ->
  game = require('./game').Game

  socket.on 'room:enter', (cxt, fn)->
    socket.join cxt.user.id
    game.join game.player(cxt.user.id), game.room(cxt.room.id)
    game.debug()
    fn cxt.user.name + ' joined ' + cxt.room.name

  socket.emit 'room:join', hello: 'world'

  socket.emit 'news', hello: 'world'

  socket.on 'my other event', (data) ->
    console.log data

  socket.on 'echo', (msg) ->
    console.log msg
    socket.emit 'echo', msg
