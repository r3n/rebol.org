REBOL [
    Title: "Scientific Calculator"
    Date: 16-Mar-2002
    Version: 0.9.4
    File: %sci-calc.r
    Author: "Ryan S. Cole"
    Purpose: {For scientific calculations.  Currently in beta, so dont use it to figure out critical information just yet.}
    Email: ryanc@iesco-dms.com
    library: [
        level: none 
        platform: none 
        type: none 
        domain: 'math 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

do load-thru/update http://www.reboltech.com/library/scripts/calculese.r
;do %calculese.r

; depth of stack shown in parens
depth: has [fathoms] [
    fathoms: copy ""
    loop length? calc-engine/stack [append fathoms "'"]
    return fathoms
]

view layout [
    backdrop effect [gradient 0x1 74.74.74 32.32.32]
    origin 6x6 space 3x3
    lcd: field "0." 262x32 right bold silver feel none font-size 22
    across
    style k button gray 50x20 [
        lcd/text: calculese face/text
        lcd/effect: compose/deep [pen 0.0.0 draw [text 2x19 (depth)]]
        show lcd
    ]
    style r k brick
    style g k leaf
    style o k orange
    style s k sienna
    style t k teal
    style a k aqua
    style b k tan

    r "CE" b "and" b "or" b "xor" b "not" return
    r "AC" a "arcsin" a "arccos" a "arctan" a #"p" "pi" return 
    g "M÷" a "sin" a "cos" a "tan" a "abs" return
    g "M×" a "exp-e" a "log-10" a "log-2" a "log-e" return
    g "M-" a "mod" a "sqr" a "exp" a "¹/x" return
    g "M+" a #"±" "±" a #"r" "rnd" a "²" a "³" return
    g "MR" k #"7" "7" k #"8" "8" k #"9" "9" t #"/" "÷" return
    g "MC" k #"4" "4" k #"5" "5" k #"6" "6" t #"*" "×" return
    s #"(" "(" k #"1" "1" k #"2" "2" k #"3" "3" t #"-" "-" return
    s #")" ")" k #"0" "0" k #"." "." o #"^M" "="  t #"+" "+"
]                                                 