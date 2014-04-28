'use strict'

model = require('../../../lib/model')

model.user.find('张三').then(
    (profile)->console.log profile
    (err)->console.log err
)
