'use strict';

config = require('../config/config')
client = config.redis

module.exports =
    user: require('./user')(client)
    game: require('./game')(client)
