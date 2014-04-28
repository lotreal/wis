"use strict"
process.env.NODE_ENV = process.env.NODE_ENV or "development"
_ = require("lodash")

###
Load environment configuration
###
module.exports = _.merge(
    require("./env/all.js")
    require("./env/" + process.env.NODE_ENV + ".js") or {}
)
