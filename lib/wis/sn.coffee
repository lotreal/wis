'use strict'
_ = require('lodash')

exports.cnNum = (n)->
    a = ['一','二','三','四','五','六','七','八','九','十','十一','十二','十三','十四','十五','十六','十七','十八','十九','廿','廿一','廿二','廿三','廿四']
    a[n-1]

exports.cnTeamname = (n)->
    n = '%s' if n == null
    prefix = [
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
        '圣域'
        '虚空'
        '逗比'
        'LOL'
        '江南'
        ]
    postfix = [
        '杰'
        '俊'
        '霸'
        '怪'
        '虎'
        '鹰'
        '少'
        '剑'
        '英'
        '仙'
        '怪'
        '圣'
        ]
    # n = cnNum(n) if _.isNumber(n)
    _.sample(prefix) + n + _.sample(postfix)
