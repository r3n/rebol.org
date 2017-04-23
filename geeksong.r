REBOL [
    Title: "99 Buckets of Bits Song"
    Date: 26-Apr-1998
    Version: 1.0.0
    File: %geeksong.r
    Author: "Owen Anderson"
    Purpose: "The geeky version :)"
    Email: oanderson04@athensacademy.org
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: 'x-file 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

sing: func [count rest] [
    prin pick ["99 buckets " "no buckets " "1 bucket " [count "buckets "]]
        min 4 count + 2
    print rest
]

for buckets 99 0 -1 [
    sing buckets "of bits on the bus,"
    sing buckets "of bits."
    print pick [
        "Take one down, short it to ground,"
        "Go to the queue, read a few,"
    ] buckets > 0
    sing buckets - 1 "of bits on the bus."
    print ""
]
                           