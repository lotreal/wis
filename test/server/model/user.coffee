'use strict'

model = require('../../../lib/model')

model.user.find('张三').then(
    (profile)->console.log profile
    (err)->console.log err
)

model.user.find('邓娟').then(
    (profile)->
        console.log profile
        model.user.id(profile.id).then(
            (profile)->console.log profile
        )
    (err)->console.log err
)
