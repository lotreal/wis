'use strict'
model = require('../../../lib/model')
Promise = require('bluebird')

p1 = model.player.get(id: '774b7a8a-c228-4cb1-8d54-268cacf78014', io: 'socket.id')
p2 = model.player.get(id: '03164946-3d58-461d-bb15-a9e09f050964', io: 'socket.id')

pl = [p2, p1, p1, p2]


pros = (model.user.id(p.id) for p in pl)

props = {}
props[p.id] = model.user.id(p.id) for p in pl

# Promise.all(pros).then (r)->
#     console.log r


Promise.props(props).then (r)->
    console.log r
