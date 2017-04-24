REBOL [
    title: "Format Decimal"
    date: 20-Aug-2010
    file: %format-decimal.r
    author:  Nick Antonaccio
    purpose: {
        Converts decimal numbers formatted in scientific notation to decimal notation.
    }
]

format-decimal: func [x /local q] [ 
    either find form x "E-" [ 
        insert/dup (head replace (first q: parse form x "E-") "." "")
            "0" ((to-integer q/3) - 1) 
        insert head q/1 "0." 
        q/1 
    ] [form x] 
] 

; examples:

format-decimal 1 / 233 
format-decimal 1 / 4 
format-decimal 5 * 7 
format-decimal 1 / 83723923452346546467
1 / to-decimal format-decimal 1 / pi