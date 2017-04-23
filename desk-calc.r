REBOL [
    Title: "Desk Calculator"
    Date: 4-Oct-2004
    Version: 1.3.0
    File: %desk-calc.r
    Author: "Ryan S. Cole"
    Purpose: "A tool for simple calculations."
    Comment: "Standard function calculator."
    Email: ryan@skurunner.com
    library: [
        level: 'intermediate 
        platform: 'all
        type: 'tool
        domain: [math GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

acc:		; Accumulator
op:			; Selected operation
mem:		; Memory storage
err: none	; Error state
reg: []		; Register stack

; For working with the displayed number...
cur-str: does [any [reg/1 acc form 0]]
cur-num: does [to-decimal cur-str]
cur-set: func [val] [
	either not either op [reg/2][reg/1] [insert reg form val] [reg/1: form val]
]

; Updates the screen...
display: does [
	if not find lcd/text: copy cur-str "." [append lcd/text "."]
	err-flag/font/color: either err [yellow][gray]
	mem-flag/font/color: either mem [green][gray]
	show [lcd err-flag mem-flag]
]

; Does the equation...
solve: does [
	if not reg/2 [insert reg reg/1]
	acc: none
	if op [err: error? try [acc: form do reform [reg/2 op 'to-decimal reg/1]]]
	reg: copy []
	op: none
]

; Handles keypresses
press: func [key] [
	err: no
	if find ".0123456789" key [
		if not either op [reg/2][reg/1] [insert reg copy ""]
		if all ["." = key  find reg/1 key] [exit]
		either all [reg/1 = "0"  key <> "."] [reg/1: copy key] [append reg/1 key]
	]
	if find "+-*/" key [
		if reg/2 [solve]
		if not reg/1 [insert reg cur-str] 
		op: key
	]
	switch key [
		"C" [acc: op: none reg: copy []]
		"E" [remove reg op: acc: none]
		"±" [cur-set negate cur-num]
		"MC" [mem: none]
		"MR" [cur-set any [mem 0]]
		"M+" [mem: add any [mem 0] cur-num]
		"M-" [mem: subtract any [mem 0] cur-num]
		"pi" [cur-set pi]
		"=" [solve]
	]
]

; Construct the screen...
view layout compose [
	backdrop effect [gradient 0x1 85.155.205 80.130.180]
	origin 10x10 space 0x0 pad 0x10 across
	style text text 15x20 bold gray  
	mem-flag: text "M"
	err-flag: text "E"
	pad 5x0  space 5x5 
	lcd: field "0." silver 170x20 right bold feel none
	return
	style k (pick [btn button] link?) 30x20 [press face/text display]
	k #"C" "C"   k "MC"  k #"7" "7"  k #"8" "8"  k #"9" "9"  k #"/" "/" return
	k #"E" "E"   k "MR"  k #"4" "4"  k #"5" "5"  k #"6" "6"  k #"*" "*" return
	k #"p" "pi"  k "M+"  k #"1" "1"  k #"2" "2"  k #"3" "3"  k #"+" "+" return
	k #"i" "±"   k "M-"  k #"0" "0"  k #"." "."  k #"=" "="  k #"-" "-"
	keycode #"^M" [press "=" display]
]                         