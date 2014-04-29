'use strict';

config = require('../config/config')
client = config.redis

module.exports = (->
    user: require('./user')(client)
    team: require('./team')(client)
    player: require('./player')(client)
)()
