'use strict'
uuid = require('node-uuid').v4
Promise = require('bluebird')

module.exports = (client)->
    INDEX_USER_NAME = 'wis:index:user:name'

    KEY_USER = (uid)->"wis:user:#{uid}"

    save = (user)->
        uid = uuid()
        client.hmset(KEY_USER(uid), user)
        client.hset(INDEX_USER_NAME, user.name, uid)

    # 通过用户名获取用户档案
    find = (name)->
        return new Promise (resolve, reject)->
            client.hget INDEX_USER_NAME, name, (err, uid)->
                return reject 'User not found.' if !uid
                client.hgetall KEY_USER(uid), (err, user)->
                    return reject 'User not found.' if !user
                    resolve id: uid, profile:user

    # 更新指定用户名的用户档案
    update = (name, profile)->
        client.hget INDEX_USER_NAME, name, (err, uid)->
            client.hmset KEY_USER(uid), profile

    # 获取所有用户档案
    all = ()->
        client.hgetall INDEX_USER_NAME, (err, indexes)->
            find(name) for name, uid of indexes

    id = (uid)->
        return new Promise (resolve, reject)->
            client.hgetall KEY_USER(uid), (err, user)->
                return reject 'User not found.' if !user
                resolve id: uid, profile:user

    return {
        all: all
        find: find
        id: id
    }
