'use strict'

_ = require('lodash')
sprintf = require('sprintf-js').sprintf

N = (n, start)->
    start = 0 unless start
    a = ['一','二','三','四','五','六','七','八','九','十','十一','十二','十三','十四','十五','十六','十七','十八','十九','廿','廿一','廿二','廿三','廿四']
    a[n-start]

exports.N = N

team = exports.team = ->
    prefix = [
        '戊戌'
        '扬州'
        '竹林'
        '天朝'
        '东北'
        '西南'
        '东南'
        '西北'
        '中原'
        '塞外'
        '关东'
        '天山'
        '华山'
        '正大'
        '江南'
        '歌乐山'
        '缙云山'
        '平顶山'
        '双龙山'
        '大渡口'
        '沙坪坝'
        '南坪'
        '鱼洞'
        '渝北'
        '春秋'
        '大唐'
        '战国'
        '绝代'
        ]
    postfix = [
        '贤'
        ['骄', {2: '双'}]
        ['杰', {2: '双'}]
        ['俊', {2: '双'}]
        ['怪', {2: '双'}]
        ['鹰', {2: '双'}]
        ['少', {2: '双'}]
        ['剑', {2: '双'}]
        ['英', {2: '双'}]
        ['圣', {2: '双'}]
        ['雄', {2: '双'}]
        ['豪', {2: '双'}]
        ['壕', {2: '双'}]
        ['虎', {2: '两'}]
        ['霸', {2: '两'}]
        ['小撮不明真相地群众', {2: '两'}]
        ['大才子', {2: '两'}]
        ]
    pre = _.sample(prefix)
    post = _.sample(postfix)

    if _.isString(post)
        return "#{pre}%s#{post}"
    else
        return ["#{pre}%s#{post[0]}", post[1]]

teamname = exports.teamname = (pattern, num)->
    if _.isString(pattern)
        return sprintf(pattern, N(num, 1))
    else
        pat = pattern[0]
        replaces = pattern[1]
        if replaces[num] != undefined
            n = replaces[num]
            return sprintf(pat, n)
        else
            return teamname(pat, num)

# console.log teamname(team(), 2)
