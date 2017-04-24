REBOL [
    file: %simple-math.r
    title: "Simple Math"
    author: "James Irwin"
    email: James.s.Irwin@mindspring.com
    date: 27-nov-2004
    version: 0.9
    purpose: "A simple little math test program."
    comment: {
	This isn't exactly what you would call efficient coding. It also has a few little 		
        problems. Not quite 1.0. To be improved!
    }
    library: [
        level: 'beginner
        platform: [all plugin]
        type: [tool]
        domain: [math]
        tested-under: 'windows
        support: none
        license: none
        see-also: none
	plugin: [size: 272x100]
    ]
    history: {
        27-nov-2004 - created it
        feb-2005 - posted it
        7-Mar-2005 - Nothing really changed. Just added history and updated the plugin thing. It wasn't working before.
    }
        
]

add-em: does [
    ;if fld-1/text = none [alert "Please fill in all required fields."]
    ;if fld-1/text = integer! false [alert "You think you can add letters?"]
    integer-1: to-integer fld-1/text
    integer-2: to-integer fld-2/text
    answer: integer-1 + integer-2
    answer-fld/text: answer
    show lay
]

subtract-it: does [
    integer-1: to-integer fld-1/text
    integer-2: to-integer fld-2/text
    answer: integer-1 - integer-2
    answer-fld/text: answer
    show lay
]

multiply-em: does [
    integer-1: to-integer fld-1/text
    integer-2: to-integer fld-2/text
    answer: integer-1 * integer-2
    answer-fld/text: answer
    show lay
]

divide-it: does [
    integer-1: to-integer fld-1/text
    integer-2: to-integer fld-2/text
    answer: integer-1 / integer-2
    answer-fld/text: answer
    show lay
]

check-fld: does [
    ;print [mold fld-1/text type? fld/text]
    either any [
        none? fld-1/text
        empty? fld-1/text
        none? fld-2/text
        empty? fld-2/text
    ]
        [alert "Please fill in all the required fields."]
        [check-fld-char]
]

check-fld-char: does [
    either any [
        fld-1/text = char?
        fld-2/text = char?
    ]
        [alert "You think you can add letters?"]
        [decide]
]

decide: does [
    if rotary-x/text = "+" [add-em]
    if rotary-x/text = "-" [subtract-it]
    if rotary-x/text = "*" [multiply-em]
    if rotary-x/text = "/" [divide-it]
]

lay: layout [
    style btn btn 80 white
    style field field 50
    across
    fld-1: field
    ;f-text: text "+" [print f-text/size]
    rotary-x: rotary 20 "+" "-" "*" "/" font-size 14
    fld-2: field
    button 20 "=" font-size 14 [check-fld]
    answer-fld: field 60
    return
    btn "Quit" [quit]
    ;btn [print lay/size]
]
;print rotary-x/state
view lay
