"use strict"
path = require("path")
session = require("../session")

###
Send partial, or 404 if it doesn't exist
###
exports.partials = (req, res) ->
    # res.clearCookie('sid')
    stripped = req.url.split(".")[0]
    requestedView = path.join("./", stripped)
    res.render requestedView, (err, html) ->
        if err
            console.log "Error rendering partial '" + requestedView + "'\n", err
            res.status 404
            res.send 404
        else
            res.send html
        return

    return


###
Send our single page app
###
exports.index = (req, res) ->
    console.log req.isAuthenticated()
    res.render "index"
    return
