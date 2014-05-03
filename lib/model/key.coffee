'use strict'

# 返回各对象在 redis 里的键名
module.exports = (->
    return {
        INDEX_USER_NAME: 'wis:index:user:name'

        user: (uid)->"wis:user:#{uid}"
    }
)()
