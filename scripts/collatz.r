REBOL [
 Title: "Collatz Sequences"
 Date: 2010-02-25
 File: %collatz.r
 Purpose: "Calculate collatz series, change start value and run."
 Library: [
        level: 'beginner
        platform: 'all
        type: [one-liner]
        domain: [math]
        tested-under: none
        license: 'public-domain
    ]
]
i: 100000000001 forever [either odd? i [i: i * 3 + 1] [i: i / 2] prin [i tab]]
