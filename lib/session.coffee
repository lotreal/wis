express = require('express')
session = require('express-session')
RedisStore = require('connect-redis')(session)
MemoryStore = express.session.MemoryStore

module.exports = (()->
    COOKIE_SECRET = 'my secret cookie'
    cookieParser = express.cookieParser(COOKIE_SECRET)

    # sessionStore = new MemoryStore()
    sessionStore = new RedisStore()

    return {
        sessionStore: sessionStore
        secret: 'SEKR319'
        key: 'sid'
        cookieSecret: COOKIE_SECRET
        cookieParser: cookieParser
    }
)()
