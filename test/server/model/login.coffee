'use strict'

User = require('../../../lib/models/user').User

login = (username, password, done)->
    User.login username, password, (err, user)->
        if err == 'Invalid user or password.'
            return done(null, false, message: err)
        return done(err) if err
        return done(null, user)

done = (e, u, m)->
    console.log e, u, m

login('罗涛', '111', done)
login('罗涛', '1112', done)
login('罗涛1', '1112', done)

User.load '94ea8811-acdb-4173-89c9-ed27fddcef26', (err, profile)->
    console.log load:err, profile

User.load '0', (err, profile)->
    console.log load:err, profile
