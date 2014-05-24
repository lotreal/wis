'use strict'

_ = require('lodash')
async = require('async')
jf = require('jsonfile')

util = require('util')

User = require('../../../lib/models/user').User


dump = './dump.json'

User.dump(dump, (err, res)->console.log 'dump ok.')
