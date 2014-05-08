jwt = require 'jsonwebtoken'

connect = require('express/node_modules/connect')
parseSignedCookie = connect.utils.parseSignedCookie
cookie = require('express/node_modules/cookie')
session = require('./session')
_ = require('lodash')
Promise = require('bluebird')
Model = require('./model')
signature = require("cookie-signature")

module.exports = (()->
    secret = 'jwt secret'

    sign = (profile)->
        jwt.sign profile, secret

    verify = (token, callback)->
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

    auth_socket = (io)->
        io.set 'authorization', (handshake, callback)->
            getSessionID(handshake).then(
                (session)->
                    token = session.token
                    return callback('Token not found') if !token

                    verify(token, (err, data)->
                        return callback(err, false)  if err
                        handshake.uid = data.uid
                        callback(null, true)
                    )

                (err)->callback(err, false)
            )

    login = (name)->
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

    return {
        sign: sign
        verify: verify
        socket: auth_socket
        login: login
        # getToken: getToken
    }
)()
