REBOL [
    Title: "Ascii math"
	File: %ascii-math.r
	Author: "Scott Wall"
	Date: 24-Feb-2009
	Version: 0.0.0
	Purpose: {Defines functions and variables for arithmetic ASCII characters}
	History: [
        0.0.0 24-Feb-2009 swall "Released"
	]
	Library: [
		level: 'beginner
		platform: 'all
		type: [function one-liner]
		domain: [scientific math]
		tested-under: [core 2.7.6.3.1 Windows XP] 
		support: none
		license: GPL
		see-also: none
        Disclaimer: {this was tested for UTF-8 and may not work for other encodings.}
	]
]

comment {
    The following constants and functions are defined and may be entered in VIM
    with the indicated keystrokes.

    Constant   Ascii     to enter in VIM (with digraphs enabled)
    ¼          188       ^k14
    ½          189       ^k12
    ¾          190       ^k34

    Function   Description   Ascii     to enter in VIM
    ²          square        178       ^k22
    ²/¯        square root   178/175   ^k22/^k'm
    ³          cube          179       ^k33
    ³/¯        cubic root    179/175   ^k33/^k'm
    ÷          divide        247       ^k-:
    ×          multiply      215       ^k*X

    Each function uses prefix notation and the operands follow the function name.
    For example ² 3 calculates the square of 3.
    Using hof.r, the formula for kinetic energy can be written as:
    K: product reduce [½ m ² v]

    }

; literal constants
¼: 0.25
½: 0.5
¾: 0.75

; functions
²: func [a [number!] /¯ ][ either ¯ [square-root a][multiply a a ] ]
³: func [a [number!] /¯ ][ either ¯ [power a divide 1 3][multiply a ² a ] ]
÷: func [a [number!] b [number!]][divide a b]
×: func [a [number!] b [number!]][multiply a b]

comment {
; the following function definitions exclude the refinement.
²: func [a [number!]][ multiply a a ]
³: func [a [number!]][ multiply a ² a ]
}

comment {
; Tests:
t1: [² (4 + 3)]
t2: [³ (2 + 3)]
t3: [²/¯ 16]
t4: [³/¯ 8]

print [t1 ": " reduce t1]
print [t2 ": " reduce t2]
print [t3 ": " reduce t3]
print [t4 ": " reduce t4]
}