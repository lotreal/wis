'use strict'
_ = require('lodash')
uuid = require('node-uuid').v4
redis = require('redis')

module.exports = (()->
    users = [
        {
            name: '罗涛'
            slogan: '银烛荧煌照绮罗，八溟争敢起波涛。'
        }
        {
            name: '邓娟'
            slogan: '邓艾心知战地宽，娟娟西月生蛾眉。'
        }
        {
            name: '于海'
            slogan: '于越城边枫叶高，海寰天下唱歌行。'
        }
        {
            name: '杨纪珂'
            slogan: '三阳本是标灵纪，黄道天清拥珮珂。'
        }
        {
            name: '邱文熙'
            slogan: '少陵杜甫兼有文，相与烜赫流淳熙。'
        }
        {
            name: '林万泉'
            slogan: '万仞云峰八石泉，泉石无情不寄书。'
        }
        {
            name: '张云泉'
            slogan: '共遇圣明千载运，神马龙龟涌圣泉。'
        }
        {
            name: '王九宁'
            slogan: '九转但能生羽翼，宁知此木超尘埃。'
        }
        {
            name: '吴勇'
            slogan: '君怀逸气还东吴，天子按剑征馀勇。'
        }
        {
            name: '杨海峰'
            slogan: '海阔天高不知处，峰峦犹自接天台。'
        }
        {
            name: '欧应燎'
            slogan: '应羡花开不凋悴，燎野焚林见所从。'
        }
    ]
    # user.id = uuid() for user in users
    # console.log users

    client = redis.createClient()

    INDEX_USER_NAME = 'wis:index:user:name'

    KEY_USER = (uid)->"wis:user:#{uid}"

    save = (user)->
        uid = uuid()
        client.hmset(KEY_USER(uid), user, redis.print)
        client.hset(INDEX_USER_NAME, user.name, uid, redis.print)

    init = ()->
        save(user) for user in users

    find = (name)->
        client.hget INDEX_USER_NAME, name, (err, uid)->
            client.hgetall KEY_USER(uid), (err, user)->
                return console.log user: user unless user
                user.id = uid
                console.log user

    update = (name, profile)->
        client.hget INDEX_USER_NAME, name, (err, uid)->
            client.hmset KEY_USER(uid), profile, redis.print

    init()
    find '欧应燎'

    update '邓娟', slogan: '邓艾心知战地宽，娟娟戏蝶过闲幔。'

    find '邓娟'
    return
)()
