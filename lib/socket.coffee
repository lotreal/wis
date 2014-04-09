module.exports = (socket) ->
  socket.emit 'news', hello: 'world'

  socket.on 'my other event', (data) ->
    console.log data

  socket.on 'echo', (msg) ->
    console.log msg
    socket.emit 'echo', msg
