Path = require('path')
Moniker = require('moniker')

file = Path.join(__dirname, './', 'words.txt')
words = (new Moniker.Dictionary()).read(file)

get = ->
    words.choose().split('-')

module.exports = get
