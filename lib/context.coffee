'use strict'

module.exports = (->
    store = {}

    return {
        get: (key)->
            return store[key]

        set: (key, obj)->
            store[key] = obj
            return obj

        one: (key, create)->
            obj = store[key]
            unless obj
                obj = create()
                store[key] = obj
            return obj
    }
)()
