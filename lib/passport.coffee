jwt = require 'jsonwebtoken'
bcrypt = require('bcrypt')

connect = require('express/node_modules/connect')
parseSignedCookie = connect.utils.parseSignedCookie
cookie = require('express/node_modules/cookie')
session = require('./session')
_ = require('lodash')
Promise = require('bluebird')
Model = require('./model')
signature = require("cookie-signature")

secret = 'jwt secret'

sign = exports.sign = (profile)->
    jwt.sign profile, secret

verify = exports.verify = (token, callback)->
    return callback('token not set') unless token
    jwt.verify(token, secret, callback)

getSessionID = (req)->
    return new Promise (resolve, reject)->
        return reject('No session.', false) if !req.headers.cookie
        session.cookieParser req, null, (err)->
            sid = req.cookies[session.key]
            return reject 'No cookie transmitted' if !sid

            sid = sid.replace('s:', '')
            sid = signature.unsign(sid, session.secret)
            req.sessionID = sid

            session.sessionStore.get sid, (err, session)->
                if (err || !session)
                    reject 'Session not found.'
                else
                    resolve session

exports.socket = (io)->
    io.set 'authorization', (handshake, callback)->
        getSessionID(handshake).then(
            (session)->
                if session.passport && session.passport.user
                    handshake.uid = session.passport.user
                    return callback(null, true)
                return callback('Session not found')
                # token = session.token
                # return callback('Token not found') if !token

                # verify(token, (err, data)->
                #     return callback(err, false)  if err
                #     handshake.uid = data.uid
                #     callback(null, true)
                # )

            (err)->callback(err, false)
        )

exports.login = (name)->
    return new Promise (resolve, reject)->
        Model.user.find(name)
        .then(
            (user)->
                console.log login: user
                token = sign(uid: user.id)
                resolve token
            (err)->
                reject 'Incorrect username or password.'
        )

getToken = (cookies)->
    return new Promise((resolve, reject)->
        cookies = cookie.parse(cookies)
        sid = parseSignedCookie(cookies.sid, session.cookieSecret)

        session.store.get(sid, (err, ok)->
            verify(ok.token, (err, data)->
                console.log err: err
                # profile = users.profile(data.name)
                resolve data
            )
        )
    )

# hash = ->
#     bcrypt.hash(password, 12, (err, hash)->)

auth = (password, hash)->
    bcrypt.compare(password, hash, (err, res)->)

# exports.deserializeUser = (id, done)->
#     User.load(id, (err, user)->
#         done(null, user)
#         )
