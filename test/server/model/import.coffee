'use strict'

User = require('../../../lib/models/user').User
dump = './dump.json'

User.import dump, (err, result)->
    console.log result
    console.log 'import ok.'
