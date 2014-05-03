'use strict'
Vote = require('../../../lib/wis/vote')

console.log '-------'

v1 = new Vote(10)
v1.vote(0, 8)
v1.vote(1, 9)
v1.vote(2, 3)
v1.vote(3, 4)
v1.vote(4, 8)
v1.vote(5, 8)
v1.vote(6, 8)
v1.vote(7, 0)

v1.vote(0, 9)

console.log getted: v1.getted

console.log percentage: v1.percentage()
console.log detail: v1.detail
console.log voted: v1.voted
console.log end: v1.end()
console.log v1.result()
for i in v1.result()
    console.log i.getted, i.voted
