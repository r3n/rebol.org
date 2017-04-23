Rebol [
    Title: "Clear-me game"
    Date: 20-Jul-2003
    File: %oneliner-clear-me.r
    Purpose: {A one-line game. A line of twenty boxes appear, each with a cross on, the object
being to remove all the crosses. Clicking on a box will toggle it and one other off and on.
Sometimes the line is easy to clear, and sometimes not. And no, I don't know if sometimes
it's impossible...}
    One-liner-length: 131
    Version: 1.0.0
    Author: "Carl Read"
    Library: [
        level: 'beginner
        platform: none
        type: [How-to FAQ one-liner]
        domain: [game]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]
view f: layout for n 0 19 1[r:(random 19)+ n // 20 append[across]load rejoin["a"n": check on[a"r"/data: a"r"/data xor on show f]"]]
