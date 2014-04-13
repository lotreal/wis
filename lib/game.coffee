class Player
  constructor: (@id)->

class Room
  constructor: (@id)->
    @players = []

  add: (player)->
    @players.push player
    return player

Game = (->
  rooms = {}
  players = {}
  cache = {}

  room = (id)->
    rooms[id] = new Room id if id not of rooms
    return rooms[id]

  player = (id)->
    players[id] = new Player id if id not of players
    return players[id]

  debug = ()->
    console.log
      rooms:   rooms
      players: players
      cache:   cache

  join = (player, room)->
    if player.id not of cache
      cache[player.id] = room.id
      room.add player
    else
      false

  exports =
    debug:  debug
    room:   room
    player: player
    join:   join

  return exports
)()

main = ()->
  context =
    user:
      id: 1
      name: 'lot'

    room:
      id: 'tuhao'
      name: '我的土豪朋友们'

  r1 = Game.room 'r1'
  u1 = Game.player 'lot'
  Game.join u1, r1
  Game.join u1, r1

  console.log Game.room 'r1'
  console.log Game.player 'lot'

  Game.debug()

main() if !module.parent

exports.Game = Game
