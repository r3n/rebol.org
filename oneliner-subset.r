Rebol [
    Title: "Check if subset"
    Date: 19-Mar-2004
    File: %oneliner-subset.r
    Purpose: {Tells you if set1 is a subset of set2. Works for both series! and bitset! values.}
    One-liner-length: 131
    Version: 1.0.0
    Author: ["Gregg Irwin" "Ladislav Mecir"]
    Library: [
        level: 'intermediate
        platform: 'all
        type: [How-to FAQ one-liner function]
        domain: [dialects]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]

subset?: func [{Returns true if A is a subset of B; false otherwise.} a [series! bitset!] b [series! bitset!]] [empty? exclude a b]

; The no-doc, no-type version. Only 40 bytes.
subset?: func [a b] [empty? exclude a b]
