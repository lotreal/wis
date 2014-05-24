'use strict'

_ = require('lodash')
Promise = require('bluebird')
bcrypt = require('bcrypt')

config = require('../config/config')
redis = config.redis
# redis = require('redis').createClient()
async = require('async')
util = require('util')
jf = require('jsonfile')

jf.spaces = 4

done = (err, result)->console.log err, result

Key = (->
    return {
        uid: 'wis:id:user'
        idxUsername: 'wis:index:username'
        idxUid: 'wis:index:uid'

        login: 'wis:login'
        profile: (id)->"wis:user:#{id}"
    }
)()

class User
    constructor: (@options) ->

    getId: -> @options.uid
    getPassword: -> @options.password

    @all = (callback)->
        redis.zrange Key.idxUid, 0, -1, callback

    @findOne = (username, callback)->
        redis.hget Key.idxUsername, username, (err, reply)->
            return callback('Invalid user or password.') if !reply
            return callback(err, reply)

    @import = (file, done)->
        async.waterfall [
            (callback)->
                jf.readFile(file, callback)
            (imports, callback)->
                bc = _.map imports, (p)->
                    return (callback)->
                        User.save(p, callback)
                async.parallelLimit(bc, 9, callback)
            ], done

    @dump = (file, done)->
        @all (err, ids)->
            finds = _.map ids, (uid)->
                return (callback)->User.load(uid, callback)
            async.parallelLimit finds, 9, (err, results)->
                console.log results
                jf.writeFile(file, results, done)


    @login = (username, password, done)->
        console.log name:username, pwd:password, done:done
        if !done
            done = (err, result)->
                console.log err:err, result:result

        ERR_MESSAGE = 'Invalid user or password.'
        async.waterfall [
            (callback)->
                redis.hget Key.idxUsername, username, (err, reply)->
                    return callback(ERR_MESSAGE, reply) if !reply
                    return callback(err, reply)
            (uid, callback)->
                redis.hget Key.login, uid, (err, reply)->
                    return callback(err, uid, reply)
            (uid, hash, callback)->
                console.log hash:hash
                bcrypt.compare password, hash, (err, login)->
                    return callback(ERR_MESSAGE, login) if !login
                    return callback(err, uid)
            (uid, callback)->
                console.log uid:uid
                User.load uid, callback
            ], done

    @load: (uid, done)->
        async.waterfall [
            (callback)->
                redis.hgetall Key.profile(uid), (err, profile)->
                    return callback('User not found.') if !profile
                    profile = _.merge(uid: uid, profile)
                    callback(err, profile)
            (profile, callback)->
                redis.hget Key.login, uid, (err, hash)->
                    profile.password = hash
                    callback(err, profile)
            ], done

    @loadProfile: (uid, done)->
        User.load uid, (err, profile)->
            return done(err) if err
            delete profile.uid
            delete profile.password
            return done(err, profile)

    @save: (data, done)->
        uid = data.uid
        password = data.password
        delete data.uid
        delete data.password

        saveIndex = (uid, done)->
            redis.zscore Key.idxUid, uid, (err, reply)->
                return done(err) if err
                return done(null, reply) if reply

                async.waterfall [
                    (callback)->
                        redis.incr Key.uid, callback
                    (num, callback)->
                        redis.zadd Key.idxUid, num, uid, (err, reply)->callback(err, num)
                    ], done

        savePassword = (done)->
            async.waterfall [
                (callback)->
                    if !password
                        bcrypt.hash('111', 12, callback)
                    else
                        callback(null, password)
                (hash, callback)->
                    redis.hset Key.login, uid, hash, (err, reply)->callback(err, hash)
                ], done

        saveProfile = (done)->
            redis.hmset Key.profile(uid), data, (err, reply)->done(err, data)

        saveUsernameIndex = (done)->
            redis.hset Key.idxUsername, data.name, uid, (err, reply)->done(err, data.name)

        async.parallel [
            (callback)->
                saveIndex uid, callback
            (callback)->
                savePassword callback
            (callback)->
                saveProfile callback
            (callback)->
                saveUsernameIndex callback
            ], done

exports.User = User
