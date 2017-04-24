REBOL [
    Title: "99 Bottles of Beer Song"
    Date: 26-Apr-1998
    File: %beersong.r
    Purpose: "The correct song. A bit more advanced."
    library: [
        level: 'beginner 
        platform: none 
        type: 'Demo 
        domain: 'x-file 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

sing: func [count rest] [
    prin pick ["99 bottles " "no bottles " "1 bottle " [count "bottles "]]
        min 4 count + 2
    print rest
]

for bottles 99 0 -1 [
    sing bottles "of beer on the wall,"
    sing bottles "of beer."
    print pick [
        "Take one down, pass it around,"
        "Go to the store, buy some more,"
    ] bottles > 0
    sing bottles - 1 "of beer on the wall."
    print ""
]
