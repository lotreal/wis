'use strict'

_ = require('lodash')

exports.sliceRnd = (collection, n)->
    head = _.sample(collection, n)
    tail = _.filter(collection, (i)->!_.contains(head, i))
    return [head, tail]
