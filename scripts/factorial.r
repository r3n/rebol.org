REBOL [
    Title: "Factorial"
    Date: 6-Jan-1999
    File: %factorial.r
    Author: "Ken Lake"
    Purpose: "Compute a factorial"
    Comment: {
      This program uses a recursive algorithm to compute factorials.
      usage: ! [a] 
      example ! 5
      120
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: 'math 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

!: func [a] [return either a > 1 [a * ! (a - 1)] [1]]

print ! 5
