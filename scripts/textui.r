REBOL [
    title: "TextUI - Textual User Interface"
    date: 22-1-2013
    file: %textui.r
    author:  Nick Antonaccio
    purpose: {
        Open source REBOL is currently being ported to platforms without
        GUI support.  This script is a simple replacement for GUIs that collect
        text input from fields and drop down lists.  Just specify a block of
        labels, and a block of default values for each field ('answers).  If the
        the 'answers block contains a nested block, the values in that
        block with be used as items in a list selector (so that users don't
        need to type a long response and/or can select from a pre-defined
        list of options - similar to a GUI text-list or drop-down selector).

        This works in both R2 and R3, with only minimal console support
        (currently operational on Android).
    }
]

; ------------------------------------------------------------------------

labels: ["First Name" "Last Name" "Favorite Color" "Address" "Phone"]
answers: copy ["" "" ["Red" "Green" "Blue" "Tan" "Black"] "" ""]

; ------------------------------------------------------------------------

; if system/build/date > 1-jan-2011 [
    newpage: copy {} loop 50 [append newpage "^/"]
; ]
if (length? labels) <> (length? answers) [
    print join newpage "'Labels and 'answers blocks must be equal length."
    halt
]
len: length? labels
lngth: 0
spaces: "    "
foreach label labels [
    if (l: length? label) > lngth [lngth: l]
]
pad: func [strng] [
    insert/dup tail str: join copy strng "" " " lngth
    join copy/part str (lngth) spaces
]
forever [
    prin newpage
    repeat i len [
        either ((answers/:i = "") or ((type? answers/:i) = block!)) [
            ans: ""
        ][
            ans: answers/:i
        ]
        prin rejoin [i ")  " pad labels/:i "|" spaces ans newline]
    ]
    prin rejoin [newline (len + 1) ")  SUBMIT"]
    choice: ask {^/^/}
    either error? try [num: to-integer choice] [] [
        either block? drop-down: answers/:num [
            print ""
            repeat i l: length? drop-down [
                prin rejoin [i ")  " pad form drop-down/:i newline]
            ]
            prin rejoin [(l + 1) ")  " pad "Other" newline]
            drop-choice: ask rejoin [{^/Select } labels/:num {:  }]
            either error? try [d-num: to-integer drop-choice] [] [
                either d-num = (l + 1) [
                    if "" <> resp: ask rejoin [
                        {^/Enter } labels/:num {:  }
                    ] [answers/:num: resp]
                ][
                    chosen: pick drop-down d-num
                    if ((chosen <> none) and (chosen <> (l + 1))) [
                        answers/:num: chosen
                    ]
                ]
            ]
        ][
            if ((num > 0) and (num <= (len + 1))) [
                either num = (len + 1) [
                    prin newpage probe answers halt  ; END ROUTINE
                ][
                    either answers/:num = "" [
                        ans: ""
                    ][
                        ans: answers/:num
                    ]
                    write clipboard:// ans
                    line: copy {}
                    loop ((length? labels/:num) + 1) [append line "-"]
                    answers/:num: ask rejoin [
                        newpage labels/:num ":  " ans "^/" line "^/^/"
                    ]
                ]
            ]
        ]
    ]
]

