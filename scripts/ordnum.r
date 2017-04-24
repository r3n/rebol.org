REBOL [
    Title: "Ordinal Number Translator"
    Date: 18-Jun-1999
    File: %ordnum.r
    Author: "Scrip Rebo"
    Purpose: "Translates ordinals (e.g. twenty) to numbers (20)"
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: 'text-processing 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

ord-to-num: func [number [string!] /local m t n] [
    m: t: n: 0
    parse number [some [
        "hundred"   (n: n * 100) |
        "thousand"  (t: n * 1000 n: 0) |
        "million"   (m: n * 1000000 n: 0) |
        "eleven"    (n: n + 11) |
        "twelve"    (n: n + 12) |
        "thirteen"  (n: n + 13) |
        "fourteen"  (n: n + 14) |
        "fifteen"   (n: n + 15) |
        "sixteen"   (n: n + 16) |
        "seventeen" (n: n + 17) |
        "eighteen"  (n: n + 18) |
        "nineteen"  (n: n + 19) |
        ["twenty" | "twentieth"] (n: n + 20) |
        ["thirty" | "thirtieth"] (n: n + 30) |
        ["forty" | "fortieth"] (n: n + 40) |
        ["fifty" | "fiftieth"] (n: n + 50) |
        ["sixty" | "sixtieth"] (n: n + 60) |
        ["seventy" | "seventieth"] (n: n + 70) |
        ["eighty" | "eightieth"] (n: n + 80) |
        ["ninety" | "ninetieth"] (n: n + 90) |
        ["one"   | "first"]   (n: n + 1) |
        ["two"   | "second"]  (n: n + 2) |
        ["three" | "third"]   (n: n + 3) |
        "four"      (n: n + 4) |
        ["five"  | "fifth"]   (n: n + 5) |
        "six"       (n: n + 6) |
        "seven"     (n: n + 7) |
        ["eight" | "eighth"]  (n: n + 8) |
        ["nine"  | "ninth"]   (n: n + 9) |
        "ten"       (n: n + 10) |
        "and" | "-" | "," | "th"
    ]]
    m + t + n
]

foreach string [
    "sixth"
    "eleventh"
    "thirtieth"
    "sixty-first"
    "nine hundred and nineteenth"
    "five hundred and fifteen thousand fifty-eighth"
] [print [string "is" ord-to-num string]]



